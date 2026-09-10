import json
from datetime import datetime
from typing import Optional, List, Union
from sqlmodel import SQLModel, Field

class WorkerProfile(SQLModel, table=True):
    __tablename__ = "worker_profiles"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(index=True, unique=True, description="Authenticated Firebase UID or Unique Phone Digits")
    full_name: str
    mobile: str
    email: Optional[str] = Field(default=None)
    location: Optional[str] = Field(default=None)
    skills: str = Field(default="[]", description="JSON encoded list of trade skills")
    experience_years: int = Field(default=0)
    cooperative_id: Optional[int] = Field(default=None, foreign_key="cooperatives.id")
    certifications: Optional[str] = Field(default="[]", description="JSON encoded list of certifications")
    verification_status: str = Field(default="PENDING", description="PENDING -> UNDER_REVIEW -> VERIFIED / REJECTED")
    rejection_reason: Optional[str] = Field(default=None)
    rating_avg: Optional[float] = Field(default=None)
    review_count: Optional[int] = Field(default=None)
    availability_status: str = Field(default="OFFLINE", description="AVAILABLE_NOW, BUSY, OFFLINE")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class WorkerProfileCreate(SQLModel):
    user_id: Optional[str] = None
    full_name: str
    mobile: str
    email: Optional[str] = None
    location: Optional[str] = None
    skills: Union[List[str], str] = []
    experience_years: int = 0
    cooperative_id: Optional[int] = None
    certifications: Optional[Union[List[str], str]] = []

class WorkerProfileUpdate(SQLModel):
    full_name: Optional[str] = None
    mobile: Optional[str] = None
    email: Optional[str] = None
    location: Optional[str] = None
    skills: Optional[Union[List[str], str]] = None
    experience_years: Optional[int] = None
    cooperative_id: Optional[int] = None
    certifications: Optional[Union[List[str], str]] = None

class WorkerProfileRead(SQLModel):
    id: int
    user_id: str
    full_name: str
    mobile: str
    email: Optional[str] = None
    location: Optional[str] = None
    skills: List[str]
    experience_years: int
    cooperative_id: Optional[int] = None
    certifications: List[str]
    verification_status: str
    rejection_reason: Optional[str] = None
    rating_avg: Optional[float] = None
    review_count: Optional[int] = None
    availability_status: str = "OFFLINE"
    created_at: datetime
    updated_at: datetime

    @classmethod
    def from_db(cls, profile: WorkerProfile) -> "WorkerProfileRead":
        skills_list = []
        if profile.skills:
            try:
                skills_list = json.loads(profile.skills) if isinstance(profile.skills, str) else profile.skills
            except Exception:
                skills_list = [s.strip() for s in profile.skills.split(",") if s.strip()]
        
        certs_list = []
        if profile.certifications:
            try:
                certs_list = json.loads(profile.certifications) if isinstance(profile.certifications, str) else profile.certifications
            except Exception:
                certs_list = [c.strip() for c in profile.certifications.split(",") if c.strip()]

        return cls(
            id=profile.id or 0,
            user_id=profile.user_id,
            full_name=profile.full_name,
            mobile=profile.mobile,
            email=profile.email,
            location=profile.location,
            skills=skills_list,
            experience_years=profile.experience_years,
            cooperative_id=profile.cooperative_id,
            certifications=certs_list,
            verification_status=profile.verification_status,
            rejection_reason=profile.rejection_reason,
            rating_avg=profile.rating_avg,
            review_count=profile.review_count,
            availability_status=getattr(profile, "availability_status", None) or "OFFLINE",
            created_at=profile.created_at,
            updated_at=profile.updated_at,
        )

class WorkerProfileVerifyRequest(SQLModel):
    verification_status: str  # UNDER_REVIEW, VERIFIED, REJECTED
    rejection_reason: Optional[str] = None
