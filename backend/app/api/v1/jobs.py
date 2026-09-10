from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, or_

from app.core.database import get_session
from app.models.job import (
    JobRequestDetail,
    JobActionResponse,
    JobPriority,
    JobRequestStatus,
    WorkerJobRecord,
    JobCustomerProfile,
    JobPricingBreakdown,
)
from app.models.booking import Booking

router = APIRouter(prefix="/worker/jobs", tags=["Worker Jobs"])
legacy_router = APIRouter(prefix="/jobs", tags=["Worker Jobs Legacy"])


class JobStatusUpdate(BaseModel):
    status: JobRequestStatus


class OtpVerificationRequest(BaseModel):
    otp: str


class JobCreateRequest(BaseModel):
    worker_user_id: str
    assigned_worker_id: Optional[int] = None
    booking_id: Optional[str] = None
    customer_id: Optional[str] = None
    customer_name: Optional[str] = None
    customer_phone: Optional[str] = None
    service_category: str = "Plumbing"
    service_subcategory: str = "Tap & Faucet Repair"
    problem_description: Optional[str] = None
    address_line: Optional[str] = None
    latitude: float = 18.4800
    longitude: float = 73.8000
    scheduled_time: Optional[str] = None
    total_min: int = 0
    total_max: int = 0
    priority: JobPriority = JobPriority.MEDIUM


def _detail(record: WorkerJobRecord) -> JobRequestDetail:
    return JobRequestDetail.from_record(record)


async def _get_record(job_id: str, session: AsyncSession) -> WorkerJobRecord:
    result = await session.execute(select(WorkerJobRecord).where(WorkerJobRecord.id == job_id))
    record = result.scalars().first()
    if record is None:
        raise HTTPException(status_code=404, detail="Worker job was not found")
    return record


async def _sync_booking_status(session: AsyncSession, record: WorkerJobRecord, status_value: str) -> None:
    if not record.booking_id:
        return
    booking_id = record.booking_id
    stmt = select(Booking).where(
        or_(Booking.booking_code == booking_id, Booking.id == int(booking_id) if booking_id.isdigit() else -1)
    )
    res = await session.execute(stmt)
    booking = res.scalars().first()
    if not booking:
        return
    mapping = {
        JobRequestStatus.ACCEPTED.value: "ACCEPTED",
        JobRequestStatus.REJECTED.value: "CANCELLED",
        JobRequestStatus.NAVIGATING.value: "ON_THE_WAY",
        JobRequestStatus.ARRIVED_OTP.value: "ARRIVED",
        JobRequestStatus.IN_PROGRESS.value: "IN_PROGRESS",
        JobRequestStatus.COMPLETED.value: "COMPLETED",
        JobRequestStatus.PENDING.value: "PENDING_WORKER",
    }
    booking.status = mapping.get(status_value, booking.status)
    booking.updated_at = datetime.utcnow()
    session.add(booking)


def _job_from_create(job_id: str, req: JobCreateRequest) -> WorkerJobRecord:
    title = req.service_subcategory or req.service_category
    customer = JobCustomerProfile(
        id=req.customer_id or "unknown",
        name=req.customer_name or "Customer",
        name_key=req.customer_name or "Customer",
        rating=0.0,
        reviews_count=0,
        phone=req.customer_phone or "",
        is_verified=False,
        total_bookings=0,
        completed_bookings=0,
        cancelled_bookings=0,
        membership_duration_key="",
        avatar_url="",
    )
    pricing = JobPricingBreakdown(
        labor_min=req.total_min,
        labor_max=req.total_max or req.total_min,
        visiting_charge_min=0,
        visiting_charge_max=0,
        materials_min=0,
        materials_max=0,
        total_min=req.total_min,
        total_max=req.total_max or req.total_min,
    )
    detail = JobRequestDetail(
        id=job_id,
        status=JobRequestStatus.PENDING,
        priority=req.priority,
        countdown_seconds=0,
        service_category_key=req.service_category,
        service_subcategory_key=req.service_subcategory,
        problem_title_key=title,
        problem_description_key=req.problem_description or title,
        ai_analysis_key="",
        difficulty_key="",
        estimated_duration_key="",
        address_line_key=req.address_line or "",
        address_line_raw=req.address_line or "",
        premise_type_key="",
        floor_key="",
        distance_km=0.0,
        worker_latitude=18.5074,
        worker_longitude=73.8077,
        customer_latitude=req.latitude,
        customer_longitude=req.longitude,
        scheduled_time_key=req.scheduled_time or "",
        scheduled_flexibility_key="",
        customer_note_key=req.problem_description or "",
        customer=customer,
        pricing=pricing,
        scope_of_work=[],
        required_tools=[],
        materials=[],
        safety_guidelines=[],
        payment_method_key="",
        cancellation_policy_key="",
        support_availability_key="",
    )
    record = WorkerJobRecord.from_detail(detail)
    record.worker_user_id = req.worker_user_id
    record.assigned_worker_id = req.assigned_worker_id
    record.booking_id = req.booking_id
    return record


@router.post("", response_model=JobRequestDetail, status_code=201)
@legacy_router.post("", response_model=JobRequestDetail, status_code=201)
async def create_job_request(
    req: JobCreateRequest,
    session: AsyncSession = Depends(get_session),
):
    job_id = f"JOB-{datetime.utcnow().strftime('%Y%m%d%H%M%S%f')}"
    record = _job_from_create(job_id, req)
    session.add(record)
    await session.commit()
    await session.refresh(record)
    return _detail(record)


@router.get("/requests/pending", response_model=List[JobRequestDetail])
async def get_pending_job_requests(
    worker_id: Optional[str] = Query(None),
    session: AsyncSession = Depends(get_session),
):
    stmt = select(WorkerJobRecord).where(
        WorkerJobRecord.status.in_([JobRequestStatus.PENDING, JobRequestStatus.EXPIRING])
    )
    if worker_id:
        stmt = stmt.where(
            or_(
                WorkerJobRecord.worker_user_id == worker_id,
                WorkerJobRecord.worker_user_id.is_(None),
            )
        )
    result = await session.execute(stmt)
    return [_detail(record) for record in result.scalars().all()]


@router.get("/{job_id}", response_model=JobRequestDetail)
async def get_job_details(job_id: str, session: AsyncSession = Depends(get_session)):
    return _detail(await _get_record(job_id, session))


async def _apply_status(record: WorkerJobRecord, new_status: JobRequestStatus, session: AsyncSession) -> JobActionResponse:
    allowed = {
        JobRequestStatus.ACCEPTED: {JobRequestStatus.PENDING, JobRequestStatus.EXPIRING},
        JobRequestStatus.NAVIGATING: {JobRequestStatus.ACCEPTED},
        JobRequestStatus.ARRIVED_OTP: {JobRequestStatus.NAVIGATING},
        JobRequestStatus.IN_PROGRESS: {JobRequestStatus.ARRIVED_OTP},
        JobRequestStatus.COMPLETED: {JobRequestStatus.IN_PROGRESS},
        JobRequestStatus.REJECTED: {JobRequestStatus.PENDING, JobRequestStatus.EXPIRING},
        JobRequestStatus.PENDING: {JobRequestStatus.ACCEPTED},
    }
    if new_status not in allowed or record.status not in allowed[new_status]:
        raise HTTPException(
            status_code=409,
            detail=f"Cannot transition {record.status} to {new_status}",
        )
    record.status = new_status
    record.updated_at = datetime.utcnow()
    await _sync_booking_status(session, record, new_status.value)
    await session.commit()
    return JobActionResponse(
        success=True,
        job_id=record.id,
        status=record.status,
        message_key="jobStatusUpdated",
    )


@router.patch("/{job_id}/status", response_model=JobActionResponse)
async def update_job_status(
    job_id: str,
    update: JobStatusUpdate,
    session: AsyncSession = Depends(get_session),
):
    record = await _get_record(job_id, session)
    return await _apply_status(record, update.status, session)


@router.post("/{job_id}/verify-otp", response_model=JobActionResponse)
async def verify_job_otp(
    job_id: str,
    request: OtpVerificationRequest,
    session: AsyncSession = Depends(get_session),
):
    record = await _get_record(job_id, session)
    if record.status != JobRequestStatus.ARRIVED_OTP:
        raise HTTPException(status_code=409, detail="Job is not awaiting doorstep OTP")
    if request.otp != record.otp_code:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    record.status = JobRequestStatus.IN_PROGRESS
    record.updated_at = datetime.utcnow()
    await _sync_booking_status(session, record, JobRequestStatus.IN_PROGRESS.value)
    await session.commit()
    return JobActionResponse(
        success=True,
        job_id=job_id,
        status=record.status,
        message_key="otpVerifiedSuccess",
    )


@router.post("/{job_id}/release", response_model=JobActionResponse)
async def release_job(job_id: str, session: AsyncSession = Depends(get_session)):
    record = await _get_record(job_id, session)
    if record.status != JobRequestStatus.ACCEPTED:
        raise HTTPException(status_code=409, detail="Only accepted jobs can be released")
    record.status = JobRequestStatus.PENDING
    record.updated_at = datetime.utcnow()
    await _sync_booking_status(session, record, JobRequestStatus.PENDING.value)
    await session.commit()
    return JobActionResponse(success=True, job_id=job_id, status=record.status, message_key="jobReleased")


@legacy_router.get("/requests/pending", response_model=List[JobRequestDetail])
async def legacy_pending(
    worker_id: Optional[str] = Query(None),
    session: AsyncSession = Depends(get_session),
):
    return await get_pending_job_requests(worker_id=worker_id, session=session)


@legacy_router.get("/{job_id}", response_model=JobRequestDetail)
async def legacy_details(job_id: str, session: AsyncSession = Depends(get_session)):
    return _detail(await _get_record(job_id, session))


@legacy_router.post("/{job_id}/accept", response_model=JobActionResponse)
async def legacy_accept(job_id: str, session: AsyncSession = Depends(get_session)):
    record = await _get_record(job_id, session)
    if record.status not in (JobRequestStatus.PENDING, JobRequestStatus.EXPIRING):
        raise HTTPException(status_code=409, detail="Job is no longer available")
    record.status = JobRequestStatus.ACCEPTED
    record.updated_at = datetime.utcnow()
    await _sync_booking_status(session, record, JobRequestStatus.ACCEPTED.value)
    await session.commit()
    return JobActionResponse(
        success=True, job_id=job_id, status=record.status, message_key="jobAcceptedSuccessToast"
    )


@legacy_router.post("/{job_id}/reject", response_model=JobActionResponse)
async def legacy_reject(job_id: str, session: AsyncSession = Depends(get_session)):
    record = await _get_record(job_id, session)
    record.status = JobRequestStatus.REJECTED
    record.updated_at = datetime.utcnow()
    await _sync_booking_status(session, record, JobRequestStatus.REJECTED.value)
    await session.commit()
    return JobActionResponse(
        success=True, job_id=job_id, status=record.status, message_key="jobRejectedSuccessToast"
    )
