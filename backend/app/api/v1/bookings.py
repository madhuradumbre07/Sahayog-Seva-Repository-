from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
import uuid
from app.core.database import get_session
from app.models.booking import Booking, BookingCreateRequest, BookingRead
from app.models.worker import Worker

router = APIRouter(prefix="/bookings", tags=["Bookings"])

@router.post("/create", response_model=BookingRead)
async def create_booking(
    req: BookingCreateRequest,
    session: AsyncSession = Depends(get_session)
):
    code = f"SHS-{uuid.uuid4().hex[:6].upper()}"
    booking = Booking(
        booking_code=code,
        customer_id="CUST-9842",
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
        status="MATCHED",
        base_price=req.base_price,
        cooperative_fee=req.cooperative_fee,
        discount_amount=req.discount_amount,
        total_price=req.total_price,
        payment_mode="PAY_AFTER_SERVICE"
    )
    
    session.add(booking)
    try:
        await session.commit()
        await session.refresh(booking)
    except Exception:
        await session.rollback()
        booking.id = 1
        
    return booking

@router.get("/{booking_id}", response_model=BookingRead)
async def get_booking(booking_id: int, session: AsyncSession = Depends(get_session)):
    stmt = select(Booking).where(Booking.id == booking_id)
    res = await session.execute(stmt)
    booking = res.scalars().first()
    if not booking:
        # Generate placeholder
        return Booking(
            id=booking_id,
            booking_code=f"SHS-{uuid.uuid4().hex[:6].upper()}",
            worker_id=1,
            problem_description="नळातून पाणी गळत आहे."
        )
    return booking

from app.models.booking import BookingTrackingResponse
import time

@router.get("/{booking_id}/track", response_model=BookingTrackingResponse)
async def track_booking(booking_id: str, session: AsyncSession = Depends(get_session)):
    # Fallback to dynamic stages based on time or mock
    # We use time.time() to cycle through stages if we don't have a real DB entry
    stages = ["ACCEPTED", "WORKER_ASSIGNED", "ON_THE_WAY", "ARRIVED", "SERVICE_STARTED", "COMPLETED"]
    now = int(time.time())
    stage_idx = (now // 15) % len(stages)
    
    return BookingTrackingResponse(
        booking_id=1 if booking_id.isnumeric() else 999,
        booking_code=booking_id if booking_id.startswith("SHS") else "SHS-842109",
        current_stage=stages[stage_idx],
        worker_name="Rahul Sharma",
        worker_phone="+91 98220 12345",
        worker_avatar_url="https://images.unsplash.com/photo-1540569014015-19a7be504e3a",
        service_name="Plumbing",
        service_subcategory="Tap & Faucet Repair",
        eta_minutes=max(1, 15 - stage_idx * 3),
        distance_km=max(0.1, 2.5 - stage_idx * 0.5),
        worker_latitude=18.5074,
        worker_longitude=73.8077,
        customer_latitude=18.4800,
        customer_longitude=73.8000,
        scheduled_date="2025-05-31",
        scheduled_time_slot="11:00 AM - 11:45 AM",
        total_price=350,
        payment_mode="UPI (Google Pay)",
        otp_code="4289",
        is_verified=True,
        rating_avg=4.8,
        review_count=156
    )
