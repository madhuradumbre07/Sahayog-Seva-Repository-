from typing import Optional
from datetime import datetime
from sqlmodel import SQLModel, Field
import uuid

class BookingBase(SQLModel):
    booking_code: str = Field(default_factory=lambda: f"SHS-{uuid.uuid4().hex[:6].upper()}")
    customer_id: str = "CUST-9842"
    worker_id: int = Field(foreign_key="workers.id")
    cooperative_id: Optional[int] = Field(default=None, foreign_key="cooperatives.id")
    
    service_category: str = "Plumbing"
    service_subcategory: str = "Tap & Faucet Repair"
    problem_description: str
    
    # Location
    address_line: str = "102, Ganesh Apartment, Warje, Pune - 411058, Maharashtra"
    latitude: float = 18.4800
    longitude: float = 73.8000
    
    # Scheduling
    scheduled_date: str = "2025-05-20"
    time_slot: str = "11:00 AM - 12:00 PM"
    special_instructions: Optional[str] = None
    
    # Status & Pricing
    status: str = "MATCHED"  # PENDING_MATCH, MATCHED, COOP_APPROVED, IN_PROGRESS, COMPLETED, CANCELLED
    base_price: int = 350
    cooperative_fee: int = 35
    discount_amount: int = 35
    total_price: int = 350
    payment_mode: str = "PAY_AFTER_SERVICE"

class Booking(BookingBase, table=True):
    __tablename__ = "bookings"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class BookingCreateRequest(SQLModel):
    worker_id: int
    service_category: str
    service_subcategory: str
    problem_description: str
    address_line: str
    latitude: float
    longitude: float
    scheduled_date: str
    time_slot: str
    special_instructions: Optional[str] = None
    base_price: int = 350
    cooperative_fee: int = 35
    discount_amount: int = 35
    total_price: int = 350

class BookingRead(BookingBase):
    id: int
    created_at: datetime

class BookingTrackingResponse(SQLModel):
    booking_id: int
    booking_code: str
    current_stage: str
    worker_name: str
    worker_phone: str
    worker_avatar_url: str
    service_name: str
    service_subcategory: str
    eta_minutes: int
    distance_km: float
    worker_latitude: float
    worker_longitude: float
    customer_latitude: float
    customer_longitude: float
    scheduled_date: str
    scheduled_time_slot: str
    total_price: int
    payment_mode: str
    otp_code: str
    is_verified: bool
    rating_avg: float
    review_count: int
