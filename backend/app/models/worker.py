from typing import Optional, List, Dict, Any
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship
import json
from app.models.worker_profile import (
    WorkerProfile,
    WorkerProfileCreate,
    WorkerProfileRead,
    WorkerProfileUpdate,
    WorkerProfileVerifyRequest,
)

class WorkerBase(SQLModel):
    cooperative_id: Optional[int] = Field(default=None, foreign_key="cooperatives.id")
    full_name: str
    full_name_mr: Optional[str] = None
    full_name_hi: Optional[str] = None
    phone_number: str
    avatar_url: str = "https://images.unsplash.com/photo-1540569014015-19a7be504e3a"
    
    # Location coordinates (Stored as float for universal DB compatibility + geometry Point)
    latitude: float
    longitude: float
    address_area: str = "Kothrud, Pune"
    
    # Primary trade & stats
    primary_trade: str = "Plumber"
    trade_subtitle: str = "Piping & Leakage Specialist"
    experience_years: int = 5
    is_available: bool = True
    availability_status: str = "AVAILABLE_NOW"  # AVAILABLE_NOW, BUSY_UNTIL_AFTERNOON, OFFLINE
    busy_until_text: Optional[str] = None
    
    # Reputation & Quality
    rating_avg: float = 4.8
    review_count: int = 156
    jobs_completed_count: int = 512
    jobs_completed_this_month: int = 14
    response_time_minutes: int = 12
    avg_completion_time_minutes: int = 35
    
    # Pricing range in INR
    hourly_rate_min: int = 250
    hourly_rate_max: int = 500
    
    # Cooperative & Welfare
    is_verified: bool = True
    member_id: str = "SHSC-24567"
    welfare_scheme_id: Optional[str] = "ESHRAM-MH-984210"
    certifications_json: str = json.dumps([
        {"title": "Plumbing Skill (NSDC Certified)", "issuer": "NSDC India"},
        {"title": "Water Safety (Government Certified)", "issuer": "Govt of Maharashtra"},
        {"title": "CPR & First Aid Certified", "issuer": "Red Cross Society"}
    ])
    skills_json: str = json.dumps([
        "Tap Repair", "Pipe Leakage", "Bathroom Fitting", "Flush Repair", "PVC Pipe Work", "Water Tank Cleaning", "Drain Cleaning"
    ])
    gallery_json: str = json.dumps([
        "https://images.unsplash.com/photo-1585704032915-c3400ca199e7",
        "https://images.unsplash.com/photo-1607472586893-edb57bdc0e39",
        "https://images.unsplash.com/photo-1581244277943-fe4a9c777189",
        "https://images.unsplash.com/photo-1504307651254-35680f356dfd"
    ])
    reviews_json: str = json.dumps([
        {"author": "प्रिया कुलकर्णी", "rating": 5.0, "comment": "वेळेवर आले आणि नळ पटकन दुरुस्त केला. खूप नम्र आणि कुशल कामगार!", "date": "2 दिवसांपूर्वी"},
        {"author": "अमित जोशी", "rating": 4.8, "comment": "Excellent work with zero extra charges. Cooperative guarantee gives great peace of mind.", "date": "1 आठवड्यापूर्वी"},
        {"author": "सचिन कदम", "rating": 4.9, "comment": "पाईप गळती पूर्णपणे थांबवली. काम अतिशय स्वच्छ केले.", "date": "2 आठवड्यांपूर्वी"}
    ])

class Worker(WorkerBase, table=True):
    __tablename__ = "workers"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: Optional[str] = Field(default=None, index=True, description="Firebase UID or phone digits")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    last_assigned_at: Optional[datetime] = None

class WorkerRead(WorkerBase):
    id: int
    created_at: datetime

class ExplainabilityMatrix(SQLModel):
    skill_match_percent: int
    proximity_percent: int
    availability_percent: int
    workload_fairness_percent: int
    overall_match_score: int
    distance_km: float
    reason_summary: str

class WorkerMatchItem(WorkerBase):
    id: int
    match_score: int
    distance_km: float
    explainability: ExplainabilityMatrix
    cooperative_society_name: str
