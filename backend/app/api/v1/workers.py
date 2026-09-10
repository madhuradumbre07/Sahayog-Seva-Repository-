import json
from datetime import datetime, date
from typing import List, Optional

from fastapi import APIRouter, Depends, Header, HTTPException, Query, Request, status
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, or_

from app.core.database import get_session
from app.models.worker import Worker
from app.models.worker_profile import (
    WorkerProfile,
    WorkerProfileCreate,
    WorkerProfileRead,
    WorkerProfileUpdate,
    WorkerProfileVerifyRequest,
)
from app.models.cooperative import Cooperative
from app.models.job import WorkerJobRecord, JobRequestStatus, JobRequestDetail
from app.models.booking import Booking

router = APIRouter(prefix="/workers", tags=["Workers Profile"])


class AvailabilityUpdate(BaseModel):
    availability_status: str


class WorkerDashboardMetrics(BaseModel):
    today_earnings: int = 0
    completed_jobs_today: int = 0
    monthly_earnings: int = 0
    rating: Optional[float] = None
    reviews_count: int = 0


class WorkerDashboardResponse(BaseModel):
    profile: Optional[WorkerProfileRead] = None
    metrics: WorkerDashboardMetrics
    pending_jobs: List[JobRequestDetail]
    appointments: List[JobRequestDetail]


def _skills_json(skills) -> str:
    if isinstance(skills, list):
        return json.dumps(skills)
    return json.dumps([s.strip() for s in str(skills).split(",") if s.strip()])


def _certs_json(certs) -> str:
    if not certs:
        return "[]"
    if isinstance(certs, list):
        return json.dumps(certs)
    return json.dumps([c.strip() for c in str(certs).split(",") if c.strip()])


async def _resolve_profile(session: AsyncSession, worker_id: str) -> Optional[WorkerProfile]:
    if worker_id.isdigit():
        stmt = select(WorkerProfile).where(
            or_(WorkerProfile.id == int(worker_id), WorkerProfile.user_id == worker_id)
        )
    else:
        stmt = select(WorkerProfile).where(WorkerProfile.user_id == worker_id)
    res = await session.execute(stmt)
    return res.scalars().first()


async def _valid_cooperative_id(session: AsyncSession, cooperative_id: Optional[int]) -> Optional[int]:
    if cooperative_id is None:
        return None
    stmt = select(Cooperative).where(Cooperative.id == cooperative_id)
    res = await session.execute(stmt)
    coop = res.scalars().first()
    return cooperative_id if coop else None


async def _upsert_directory_worker(session: AsyncSession, profile: WorkerProfile, verified: bool) -> None:
    stmt = select(Worker).where(Worker.user_id == profile.user_id)
    res = await session.execute(stmt)
    worker = res.scalars().first()
    if worker is None and profile.mobile:
        digits = profile.mobile.replace("+91", "").strip()[-10:]
        stmt = select(Worker).where(Worker.phone_number.contains(digits))
        res = await session.execute(stmt)
        worker = res.scalars().first()

    skills = []
    try:
        skills = json.loads(profile.skills) if profile.skills else []
    except Exception:
        skills = [s.strip() for s in (profile.skills or "").split(",") if s.strip()]
    primary = skills[0] if skills else "General"

    if worker is None:
        worker = Worker(
            user_id=profile.user_id,
            full_name=profile.full_name,
            phone_number=profile.mobile,
            latitude=18.5074,
            longitude=73.8077,
            address_area=profile.location or "Pune",
            primary_trade=primary,
            trade_subtitle=", ".join(skills[:3]) if skills else "Registered worker",
            experience_years=profile.experience_years,
            is_available=verified,
            availability_status="AVAILABLE_NOW" if verified else "OFFLINE",
            rating_avg=profile.rating_avg or 0.0,
            review_count=profile.review_count or 0,
            is_verified=verified,
            cooperative_id=profile.cooperative_id,
            skills_json=profile.skills or "[]",
            certifications_json=profile.certifications or "[]",
        )
    else:
        worker.user_id = profile.user_id
        worker.full_name = profile.full_name
        worker.phone_number = profile.mobile
        worker.address_area = profile.location or worker.address_area
        worker.primary_trade = primary
        worker.trade_subtitle = ", ".join(skills[:3]) if skills else worker.trade_subtitle
        worker.experience_years = profile.experience_years
        worker.is_verified = verified
        worker.is_available = verified and (profile.availability_status in ("AVAILABLE_NOW", "ONLINE"))
        worker.cooperative_id = profile.cooperative_id
        worker.skills_json = profile.skills or worker.skills_json
        worker.certifications_json = profile.certifications or worker.certifications_json
        if profile.rating_avg is not None:
            worker.rating_avg = profile.rating_avg
        if profile.review_count is not None:
            worker.review_count = profile.review_count
        if not verified:
            worker.is_available = False
            worker.availability_status = "OFFLINE"

    session.add(worker)


async def _register_worker(
    req: WorkerProfileCreate,
    x_user_id: Optional[str],
    session: AsyncSession,
) -> WorkerProfileRead:
    user_id = (req.user_id or x_user_id or "").strip()
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User ID is required for worker registration.",
        )

    if not req.full_name or not req.full_name.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Full name cannot be empty.",
        )

    clean_mobile = req.mobile.strip() if req.mobile else ""
    if not clean_mobile or len(clean_mobile.replace("+91", "").strip()) < 10:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A valid 10-digit mobile number is required.",
        )

    if req.experience_years < 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Experience years cannot be negative.",
        )

    stmt = select(WorkerProfile).where(WorkerProfile.user_id == user_id)
    res = await session.execute(stmt)
    existing = res.scalars().first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Worker profile already registered for user ID '{user_id}'.",
        )

    coop_id = await _valid_cooperative_id(session, req.cooperative_id)
    profile = WorkerProfile(
        user_id=user_id,
        full_name=req.full_name.strip(),
        mobile=clean_mobile,
        email=req.email.strip() if req.email else None,
        location=req.location.strip() if req.location else None,
        skills=_skills_json(req.skills),
        experience_years=req.experience_years,
        cooperative_id=coop_id,
        certifications=_certs_json(req.certifications),
        verification_status="PENDING",
        availability_status="OFFLINE",
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    session.add(profile)
    await session.commit()
    await session.refresh(profile)
    return WorkerProfileRead.from_db(profile)


@router.post("/register", response_model=WorkerProfileRead, status_code=status.HTTP_201_CREATED)
@router.post("/register/", response_model=WorkerProfileRead, status_code=status.HTTP_201_CREATED)
@router.post("", response_model=WorkerProfileRead, status_code=status.HTTP_201_CREATED)
@router.post("/", response_model=WorkerProfileRead, status_code=status.HTTP_201_CREATED)
async def register_worker_profile(
    req: WorkerProfileCreate,
    x_user_id: Optional[str] = Header(None, alias="X-User-Id"),
    session: AsyncSession = Depends(get_session),
):
    """Registers a worker in PostgreSQL with verification_status=PENDING."""
    return await _register_worker(req, x_user_id, session)


@router.api_route(
    "/register",
    methods=["PUT", "PATCH"],
    response_model=WorkerProfileRead,
    status_code=status.HTTP_201_CREATED,
)
async def register_worker_profile_compat(
    req: WorkerProfileCreate,
    x_user_id: Optional[str] = Header(None, alias="X-User-Id"),
    session: AsyncSession = Depends(get_session),
):
    """Accept PUT/PATCH to /register so misconfigured clients are not 405'd."""
    return await _register_worker(req, x_user_id, session)


@router.put("/{worker_id}", response_model=WorkerProfileRead)
async def update_worker_profile(
    worker_id: str,
    req: WorkerProfileUpdate,
    session: AsyncSession = Depends(get_session),
):
    if worker_id in ("register", "pending", "dashboard"):
        raise HTTPException(
            status_code=status.HTTP_405_METHOD_NOT_ALLOWED,
            detail="Use POST /api/v1/workers/register to create a worker profile.",
        )

    profile = await _resolve_profile(session, worker_id)
    if not profile:
        profile = WorkerProfile(
            user_id=worker_id,
            full_name=req.full_name.strip() if req.full_name else "Worker",
            mobile=req.mobile.strip() if req.mobile else "0000000000",
            email=req.email.strip() if req.email else None,
            location=req.location.strip() if req.location else None,
            skills=_skills_json(req.skills) if req.skills is not None else "[]",
            experience_years=req.experience_years or 0,
            cooperative_id=await _valid_cooperative_id(session, req.cooperative_id),
            certifications=_certs_json(req.certifications) if req.certifications is not None else "[]",
            verification_status="PENDING",
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow(),
        )
    else:
        if req.full_name is not None and req.full_name.strip():
            profile.full_name = req.full_name.strip()
        if req.mobile is not None and req.mobile.strip():
            profile.mobile = req.mobile.strip()
        if req.email is not None:
            profile.email = req.email.strip()
        if req.location is not None:
            profile.location = req.location.strip()
        if req.skills is not None:
            profile.skills = _skills_json(req.skills)
        if req.experience_years is not None:
            profile.experience_years = req.experience_years
        if req.cooperative_id is not None:
            profile.cooperative_id = await _valid_cooperative_id(session, req.cooperative_id)
        if req.certifications is not None:
            profile.certifications = _certs_json(req.certifications)
        profile.updated_at = datetime.utcnow()

    session.add(profile)
    await session.commit()
    await session.refresh(profile)
    return WorkerProfileRead.from_db(profile)


@router.get("/pending", response_model=List[WorkerProfileRead])
async def get_pending_workers(
    verification_status: Optional[str] = Query(None, description="Optional status filter"),
    session: AsyncSession = Depends(get_session),
):
    if verification_status:
        stmt = select(WorkerProfile).where(WorkerProfile.verification_status == verification_status.upper())
    else:
        stmt = (
            select(WorkerProfile)
            .where(
                or_(
                    WorkerProfile.verification_status == "PENDING",
                    WorkerProfile.verification_status == "UNDER_REVIEW",
                )
            )
            .order_by(WorkerProfile.created_at.desc())
        )
    res = await session.execute(stmt)
    return [WorkerProfileRead.from_db(p) for p in res.scalars().all()]


@router.get("/{worker_id}/dashboard", response_model=WorkerDashboardResponse)
async def get_worker_dashboard(
    worker_id: str,
    session: AsyncSession = Depends(get_session),
):
    profile = await _resolve_profile(session, worker_id)
    profile_read = WorkerProfileRead.from_db(profile) if profile else None
    user_key = profile.user_id if profile else worker_id

    jobs_stmt = select(WorkerJobRecord).where(
        or_(
            WorkerJobRecord.worker_user_id == user_key,
            WorkerJobRecord.worker_user_id == worker_id,
        )
    )
    jobs_res = await session.execute(jobs_stmt)
    jobs = list(jobs_res.scalars().all())

    pending = [
        JobRequestDetail.from_record(j)
        for j in jobs
        if j.status in (JobRequestStatus.PENDING, JobRequestStatus.EXPIRING)
    ]
    appointments = [
        JobRequestDetail.from_record(j)
        for j in jobs
        if j.status
        in (
            JobRequestStatus.ACCEPTED,
            JobRequestStatus.NAVIGATING,
            JobRequestStatus.ARRIVED_OTP,
            JobRequestStatus.IN_PROGRESS,
        )
    ]

    today = date.today()
    completed = [j for j in jobs if j.status == JobRequestStatus.COMPLETED]
    today_completed = [j for j in completed if (j.updated_at or j.created_at).date() == today]
    month_completed = [
        j for j in completed if (j.updated_at or j.created_at).month == today.month and (j.updated_at or j.created_at).year == today.year
    ]

    def _job_pay(job: WorkerJobRecord) -> int:
        pricing = job.pricing or {}
        return int(pricing.get("total_min") or pricing.get("total_max") or 0)

    metrics = WorkerDashboardMetrics(
        today_earnings=sum(_job_pay(j) for j in today_completed),
        completed_jobs_today=len(today_completed),
        monthly_earnings=sum(_job_pay(j) for j in month_completed),
        rating=profile.rating_avg if profile else None,
        reviews_count=profile.review_count or 0 if profile else 0,
    )
    return WorkerDashboardResponse(
        profile=profile_read,
        metrics=metrics,
        pending_jobs=pending,
        appointments=appointments,
    )


@router.patch("/{worker_id}/availability", response_model=WorkerProfileRead)
async def update_availability(
    worker_id: str,
    req: AvailabilityUpdate,
    session: AsyncSession = Depends(get_session),
):
    profile = await _resolve_profile(session, worker_id)
    if not profile:
        raise HTTPException(status_code=404, detail=f"Worker profile '{worker_id}' not found.")
    status_map = {
        "ONLINE": "AVAILABLE_NOW",
        "AVAILABLE_NOW": "AVAILABLE_NOW",
        "BUSY": "BUSY",
        "OFFLINE": "OFFLINE",
    }
    mapped = status_map.get(req.availability_status.upper())
    if not mapped:
        raise HTTPException(status_code=400, detail="Invalid availability status.")
    profile.availability_status = mapped
    profile.updated_at = datetime.utcnow()
    session.add(profile)

    wstmt = select(Worker).where(Worker.user_id == profile.user_id)
    wres = await session.execute(wstmt)
    worker = wres.scalars().first()
    if worker:
        worker.availability_status = mapped
        worker.is_available = mapped == "AVAILABLE_NOW"
        session.add(worker)

    await session.commit()
    await session.refresh(profile)
    return WorkerProfileRead.from_db(profile)


@router.get("/{worker_id}")
async def get_worker_profile(
    worker_id: str,
    customer_lat: float = Query(18.4800),
    customer_lon: float = Query(73.8000),
    session: AsyncSession = Depends(get_session),
):
    if worker_id == "register":
        raise HTTPException(
            status_code=status.HTTP_405_METHOD_NOT_ALLOWED,
            detail="Use POST /api/v1/workers/register to create a worker profile.",
        )
    profile = await _resolve_profile(session, worker_id)
    if profile:
        return WorkerProfileRead.from_db(profile)

    if worker_id.isdigit():
        w_id = int(worker_id)
        stmt = select(Worker).where(Worker.id == w_id)
        res = await session.execute(stmt)
        worker = res.scalars().first()
        if worker:
            from app.services.fair_allocation_engine import FairAllocationEngine

            coop = None
            if worker.cooperative_id:
                coop_stmt = select(Cooperative).where(Cooperative.id == worker.cooperative_id)
                coop_res = await session.execute(coop_stmt)
                coop = coop_res.scalars().first()
            return FairAllocationEngine.compute_worker_match(
                worker=worker,
                coop=coop,
                customer_lat=customer_lat,
                customer_lon=customer_lon,
            )

    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=f"Worker profile for '{worker_id}' not found.",
    )


@router.post("/{worker_id}")
async def post_worker_alias(
    worker_id: str,
    request: Request,
    session: AsyncSession = Depends(get_session),
    x_user_id: Optional[str] = Header(None, alias="X-User-Id"),
):
    """POST /workers/{id} used to 405; treat /register or create-body as registration."""
    body = await request.json()
    if worker_id == "register":
        req = WorkerProfileCreate.model_validate(body)
        return await _register_worker(req, x_user_id, session)
    raise HTTPException(
        status_code=status.HTTP_405_METHOD_NOT_ALLOWED,
        detail="Use POST /api/v1/workers/register to create a worker profile.",
    )


@router.patch("/{worker_id}/verify", response_model=WorkerProfileRead)
async def verify_worker_profile(
    worker_id: str,
    req: WorkerProfileVerifyRequest,
    x_user_role: Optional[str] = Header(None, alias="X-User-Role"),
    x_admin_role: Optional[str] = Header(None, alias="X-Admin-Role"),
    session: AsyncSession = Depends(get_session),
):
    role = (x_admin_role or x_user_role or "").lower()
    if role not in ["admin", "cooperative"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Forbidden: Admin authorization required to verify or reject worker profiles.",
        )

    new_status = req.verification_status.upper()
    valid_statuses = ["PENDING", "UNDER_REVIEW", "VERIFIED", "REJECTED"]
    if new_status not in valid_statuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid status '{req.verification_status}'. Must be one of {valid_statuses}.",
        )

    profile = await _resolve_profile(session, worker_id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Worker profile '{worker_id}' not found.",
        )

    profile.verification_status = new_status
    if req.rejection_reason:
        profile.rejection_reason = req.rejection_reason.strip()
    if new_status == "VERIFIED":
        profile.availability_status = profile.availability_status or "AVAILABLE_NOW"
    if new_status == "REJECTED":
        profile.availability_status = "OFFLINE"
    profile.updated_at = datetime.utcnow()
    session.add(profile)
    await _upsert_directory_worker(session, profile, verified=(new_status == "VERIFIED"))
    await session.commit()
    await session.refresh(profile)
    return WorkerProfileRead.from_db(profile)
