from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum
from sqlalchemy import Column, JSON
from sqlmodel import SQLModel, Field

class JobPriority(str, Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    URGENT = "URGENT"

class JobRequestStatus(str, Enum):
    PENDING = "PENDING"
    EXPIRING = "EXPIRING"
    EXPIRED = "EXPIRED"
    ACCEPTED = "ACCEPTED"
    REJECTED = "REJECTED"
    ACCEPTED_BY_OTHER = "ACCEPTED_BY_OTHER"
    NAVIGATING = "NAVIGATING"
    ARRIVED_OTP = "ARRIVED_OTP"
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"

class JobCustomerProfile(BaseModel):
    id: str = "CUST-9842"
    name: str = "Sandeep Patil"
    name_key: str = "customerSandeepPatil"
    avatar_url: str = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d"
    rating: float = 4.7
    reviews_count: int = 84
    phone: str = "+91 98765 43210"
    is_verified: bool = True
    total_bookings: int = 12
    completed_bookings: int = 10
    cancelled_bookings: int = 1
    membership_duration_key: str = "memberTwoMonthsAgo"

class JobScopeItem(BaseModel):
    id: str
    title_key: str
    is_done: bool = False

class JobToolItem(BaseModel):
    id: str
    name_key: str
    icon_name: str

class JobMaterialItem(BaseModel):
    id: str
    name_key: str
    price_min: int
    price_max: int

class JobPricingBreakdown(BaseModel):
    labor_min: int = 150
    labor_max: int = 300
    visiting_charge_min: int = 50
    visiting_charge_max: int = 100
    materials_min: int = 50
    materials_max: int = 150
    total_min: int = 250
    total_max: int = 500

class JobRequestDetail(BaseModel):
    id: str = "REQ-250531-0178"
    status: JobRequestStatus = JobRequestStatus.PENDING
    priority: JobPriority = JobPriority.HIGH
    countdown_seconds: int = 165
    service_category_key: str = "servicePlumber"
    service_subcategory_key: str = "tapFaucetRepair"
    problem_title_key: str = "tapFaucetRepair"
    problem_description_key: str = "jobProblemTapDesc"
    ai_analysis_key: str = "jobAiAnalysisDesc"
    difficulty_key: str = "difficultyEasy"
    estimated_duration_key: str = "estDuration30to45"
    address_line_key: str = "jobAddressGaneshApts"
    address_line_raw: str = "102, Ganesh Apartments, Warje, Pune - 411058, Maharashtra"
    premise_type_key: str = "premiseApartment"
    floor_key: str = "floorSecond"
    distance_km: float = 1.2
    worker_latitude: float = 18.5074
    worker_longitude: float = 73.8077
    customer_latitude: float = 18.4800
    customer_longitude: float = 73.8000
    scheduled_time_key: str = "jobScheduledTimeToday"
    scheduled_flexibility_key: str = "flexibility30mins"
    customer_note_key: str = "jobCustomerNoteText"
    customer: JobCustomerProfile = Field(default_factory=JobCustomerProfile)
    pricing: JobPricingBreakdown = Field(default_factory=JobPricingBreakdown)
    scope_of_work: List[JobScopeItem] = Field(default_factory=lambda: [
        JobScopeItem(id="scope_1", title_key="scopeTapInspection"),
        JobScopeItem(id="scope_2", title_key="scopeWasherReplacement"),
        JobScopeItem(id="scope_3", title_key="scopeStopLeakage"),
        JobScopeItem(id="scope_4", title_key="scopeWaterFlowTest"),
        JobScopeItem(id="scope_5", title_key="scopeCleanupPostWork"),
    ])
    required_tools: List[JobToolItem] = Field(default_factory=lambda: [
        JobToolItem(id="tool_1", name_key="toolAdjustableWrench", icon_name="build"),
        JobToolItem(id="tool_2", name_key="toolScrewdriver", icon_name="handyman"),
        JobToolItem(id="tool_3", name_key="toolTapKey", icon_name="vpn_key"),
        JobToolItem(id="tool_4", name_key="toolPlumberTape", icon_name="tape"),
        JobToolItem(id="tool_5", name_key="toolBasinWrench", icon_name="plumbing"),
    ])
    materials: List[JobMaterialItem] = Field(default_factory=lambda: [
        JobMaterialItem(id="mat_1", name_key="matWasherOring", price_min=20, price_max=40),
        JobMaterialItem(id="mat_2", name_key="matPlumberTape", price_min=10, price_max=20),
        JobMaterialItem(id="mat_3", name_key="matOtherRequired", price_min=20, price_max=40),
    ])
    safety_guidelines: List[str] = Field(default_factory=lambda: [
        "safetyElectricalPrecaution",
        "safetyTurnOffMainValve",
        "safetyUseProtectiveGear",
        "safetyPoliteCommunication",
    ])
    payment_method_key: str = "payMethodOnlineUpi"
    cancellation_policy_key: str = "jobCancelPolicy2Hours"
    support_availability_key: str = "support24x7Available"

    @classmethod
    def from_record(cls, record: "WorkerJobRecord") -> "JobRequestDetail":
        values = record.model_dump(
            exclude={
                "id",
                "status",
                "created_at",
                "updated_at",
                "otp_code",
                "worker_user_id",
                "booking_id",
                "assigned_worker_id",
            }
        )
        values.update(id=record.id, status=record.status)
        return cls(**values)


class WorkerJobRecord(SQLModel, table=True):
    __tablename__ = "worker_jobs"

    id: str = Field(primary_key=True)
    status: JobRequestStatus = Field(default=JobRequestStatus.PENDING, index=True)
    priority: JobPriority = Field(default=JobPriority.HIGH)
    countdown_seconds: int = 165
    service_category_key: str = "servicePlumber"
    service_subcategory_key: str = "tapFaucetRepair"
    problem_title_key: str = "tapFaucetRepair"
    problem_description_key: str = "jobProblemTapDesc"
    ai_analysis_key: str = "jobAiAnalysisDesc"
    difficulty_key: str = "difficultyEasy"
    estimated_duration_key: str = "estDuration30to45"
    address_line_key: str = "jobAddressGaneshApts"
    address_line_raw: str = "102, Ganesh Apartments, Warje, Pune - 411058, Maharashtra"
    premise_type_key: str = "premiseApartment"
    floor_key: str = "floorSecond"
    distance_km: float = 1.2
    worker_latitude: float = 18.5074
    worker_longitude: float = 73.8077
    customer_latitude: float = 18.4800
    customer_longitude: float = 73.8000
    scheduled_time_key: str = "jobScheduledTimeToday"
    scheduled_flexibility_key: str = "flexibility30mins"
    customer_note_key: str = "jobCustomerNoteText"
    customer: Dict[str, Any] = Field(default_factory=lambda: JobCustomerProfile().model_dump(), sa_column=Column(JSON, nullable=False))
    pricing: Dict[str, Any] = Field(default_factory=lambda: JobPricingBreakdown().model_dump(), sa_column=Column(JSON, nullable=False))
    scope_of_work: List[Dict[str, Any]] = Field(default_factory=list, sa_column=Column(JSON, nullable=False))
    required_tools: List[Dict[str, Any]] = Field(default_factory=list, sa_column=Column(JSON, nullable=False))
    materials: List[Dict[str, Any]] = Field(default_factory=list, sa_column=Column(JSON, nullable=False))
    safety_guidelines: List[str] = Field(default_factory=list, sa_column=Column(JSON, nullable=False))
    payment_method_key: str = "payMethodOnlineUpi"
    cancellation_policy_key: str = "jobCancelPolicy2Hours"
    support_availability_key: str = "support24x7Available"
    otp_code: str = "4289"
    worker_user_id: Optional[str] = Field(default=None, index=True)
    booking_id: Optional[str] = Field(default=None, index=True)
    assigned_worker_id: Optional[int] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    @classmethod
    def from_detail(cls, detail: JobRequestDetail) -> "WorkerJobRecord":
        values = detail.model_dump()
        values.pop("customer")
        values.pop("pricing")
        values.pop("scope_of_work")
        values.pop("required_tools")
        values.pop("materials")
        return cls(
            **values,
            customer=detail.customer.model_dump(),
            pricing=detail.pricing.model_dump(),
            scope_of_work=[item.model_dump() for item in detail.scope_of_work],
            required_tools=[item.model_dump() for item in detail.required_tools],
            materials=[item.model_dump() for item in detail.materials],
        )

class JobActionResponse(BaseModel):
    success: bool
    job_id: str
    status: JobRequestStatus
    message_key: str
