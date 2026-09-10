from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, or_
import uuid
from datetime import datetime
from typing import Optional, List

from app.core.database import get_session
from app.models.booking import Booking, BookingCreateRequest, BookingRead, BookingTrackingResponse
from app.models.notification import Notification
from app.models.worker import Worker
from app.models.worker_profile import WorkerProfile
from app.models.job import (
    WorkerJobRecord,
    JobRequestDetail,
    JobRequestStatus,
    JobPriority,
    JobCustomerProfile,
    JobPricingBreakdown,
)

router = APIRouter(prefix="/bookings", tags=["Bookings"])


def _job_from_booking(booking: Booking, worker: Optional[Worker], req: BookingCreateRequest) -> WorkerJobRecord:
    worker_user_id = None
    if worker and getattr(worker, "user_id", None):
        worker_user_id = worker.user_id
    title = req.service_subcategory or req.service_category
    customer = JobCustomerProfile(
        id=req.customer_id or booking.customer_id,
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
        labor_min=req.base_price,
        labor_max=req.total_price,
        visiting_charge_min=0,
        visiting_charge_max=0,
        materials_min=0,
        materials_max=0,
        total_min=req.total_price,
        total_max=req.total_price,
    )
    detail = JobRequestDetail(
        id=f"JOB-{booking.booking_code}",
        status=JobRequestStatus.PENDING,
        priority=JobPriority.MEDIUM,
        countdown_seconds=0,
        service_category_key=req.service_category,
        service_subcategory_key=req.service_subcategory,
        problem_title_key=title,
        problem_description_key=req.problem_description,
        ai_analysis_key="",
        difficulty_key="",
        estimated_duration_key="",
        address_line_key=req.address_line,
        address_line_raw=req.address_line,
        premise_type_key="",
        floor_key="",
        distance_km=0.0,
        worker_latitude=worker.latitude if worker else 18.5074,
        worker_longitude=worker.longitude if worker else 73.8077,
        customer_latitude=req.latitude,
        customer_longitude=req.longitude,
        scheduled_time_key=req.time_slot,
        scheduled_flexibility_key="",
        customer_note_key=req.special_instructions or req.problem_description,
        customer=customer,
        pricing=pricing,
        scope_of_work=[],
        required_tools=[],
        materials=[],
        safety_guidelines=[],
        payment_method_key=booking.payment_mode,
        cancellation_policy_key="",
        support_availability_key="",
    )
    record = WorkerJobRecord.from_detail(detail)
    record.worker_user_id = worker_user_id
    record.assigned_worker_id = booking.worker_id
    record.booking_id = booking.booking_code
    return record


@router.post("/create", response_model=BookingRead)
async def create_booking(
    req: BookingCreateRequest,
    x_user_id: Optional[str] = Header(None, alias="X-User-Id"),
    session: AsyncSession = Depends(get_session),
):
    code = f"SHS-{uuid.uuid4().hex[:6].upper()}"
    customer_id = req.customer_id or x_user_id or "unknown"
    booking = Booking(
        booking_code=code,
        customer_id=customer_id,
        worker_id=req.worker_id,
        service_category=req.service_category,
        service_subcategory=req.service_subcategory,
        problem_description=req.problem_description,
        address_line=req.address_line,
        latitude=req.latitude,
        longitude=req.longitude,
        scheduled_date=req.scheduled_date,
        time_slot=req.time_slot,
        special_instructions=req.special_instructions,
        status="PENDING_WORKER",
        base_price=req.base_price,
        cooperative_fee=req.cooperative_fee,
        discount_amount=req.discount_amount,
        total_price=req.total_price,
        payment_mode="PAY_AFTER_SERVICE",
    )
    session.add(booking)
    await session.commit()
    await session.refresh(booking)

    worker = None
    wres = await session.execute(select(Worker).where(Worker.id == req.worker_id))
    worker = wres.scalars().first()

    session.add(_job_from_booking(booking, worker, req))
    
    # Notify customer of confirmed booking
    session.add(
        Notification(
            user_id=customer_id,
            title="Booking Confirmed",
            message=f"Your booking {code} for {req.service_subcategory or req.service_category} has been placed. Nearby workers are being notified.",
            type="BOOKING",
            related_id=booking.booking_code,
        )
    )
    await session.commit()
    await session.refresh(booking)
    return booking


@router.get("/customer/{customer_id}", response_model=List[BookingRead])
async def get_customer_bookings(customer_id: str, session: AsyncSession = Depends(get_session)):
    stmt = (
        select(Booking)
        .where(Booking.customer_id == customer_id)
        .order_by(Booking.created_at.desc())
    )
    res = await session.execute(stmt)
    return res.scalars().all()


@router.get("/{booking_id}", response_model=BookingRead)
async def get_booking(booking_id: int, session: AsyncSession = Depends(get_session)):
    stmt = select(Booking).where(Booking.id == booking_id)
    res = await session.execute(stmt)
    booking = res.scalars().first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    return booking


@router.get("/{booking_id}/track", response_model=BookingTrackingResponse)
async def track_booking(booking_id: str, session: AsyncSession = Depends(get_session)):
    stmt = select(Booking).where(
        or_(
            Booking.booking_code == booking_id,
            Booking.id == int(booking_id) if booking_id.isdigit() else -1,
        )
    )
    res = await session.execute(stmt)
    booking = res.scalars().first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    worker = None
    wres = await session.execute(select(Worker).where(Worker.id == booking.worker_id))
    worker = wres.scalars().first()

    profile = None
    if worker and worker.user_id:
        pres = await session.execute(select(WorkerProfile).where(WorkerProfile.user_id == worker.user_id))
        profile = pres.scalars().first()

    job = None
    jres = await session.execute(select(WorkerJobRecord).where(WorkerJobRecord.booking_id == booking.booking_code))
    job = jres.scalars().first()

    stage = booking.status
    if job:
        job_stage = {
            JobRequestStatus.PENDING: "PENDING_WORKER",
            JobRequestStatus.ACCEPTED: "ACCEPTED",
            JobRequestStatus.NAVIGATING: "ON_THE_WAY",
            JobRequestStatus.ARRIVED_OTP: "ARRIVED",
            JobRequestStatus.IN_PROGRESS: "SERVICE_STARTED",
            JobRequestStatus.COMPLETED: "COMPLETED",
            JobRequestStatus.REJECTED: "CANCELLED",
        }
        stage = job_stage.get(job.status, booking.status)

    return BookingTrackingResponse(
        booking_id=booking.id or 0,
        booking_code=booking.booking_code,
        current_stage=stage,
        worker_name=(worker.full_name if worker else (profile.full_name if profile else "")),
        worker_phone=(worker.phone_number if worker else (profile.mobile if profile else "")),
        worker_avatar_url=worker.avatar_url if worker else "",
        service_name=booking.service_category,
        service_subcategory=booking.service_subcategory,
        eta_minutes=0,
        distance_km=0.0,
        worker_latitude=worker.latitude if worker else booking.latitude,
        worker_longitude=worker.longitude if worker else booking.longitude,
        customer_latitude=booking.latitude,
        customer_longitude=booking.longitude,
        scheduled_date=booking.scheduled_date,
        scheduled_time_slot=booking.time_slot,
        total_price=booking.total_price,
        payment_mode=booking.payment_mode,
        otp_code=job.otp_code if job else "",
        is_verified=bool(worker and worker.is_verified),
        rating_avg=worker.rating_avg if worker else (profile.rating_avg if profile and profile.rating_avg else 0.0),
        review_count=worker.review_count if worker else (profile.review_count if profile and profile.review_count else 0),
    )


@router.post("/{booking_id}/cancel", response_model=BookingRead)
async def cancel_booking(booking_id: str, session: AsyncSession = Depends(get_session)):
    stmt = select(Booking).where(
        or_(
            Booking.booking_code == booking_id,
            Booking.id == int(booking_id) if booking_id.isdigit() else -1,
        )
    )
    res = await session.execute(stmt)
    booking = res.scalars().first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    booking.status = "CANCELLED"
    session.add(booking)

    # Cancel associated job record if present
    jres = await session.execute(select(WorkerJobRecord).where(WorkerJobRecord.booking_id == booking.booking_code))
    job = jres.scalars().first()
    if job:
        job.status = JobRequestStatus.REJECTED
        session.add(job)

    # Create cancellation notification
    session.add(
        Notification(
            user_id=booking.customer_id,
            title="Booking Cancelled",
            message=f"Booking {booking.booking_code} ({booking.service_subcategory or booking.service_category}) was cancelled.",
            type="BOOKING",
            related_id=booking.booking_code,
        )
    )

    await session.commit()
    await session.refresh(booking)
    return booking

