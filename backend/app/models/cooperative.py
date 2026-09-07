from typing import Optional, List
from datetime import datetime
from sqlmodel import SQLModel, Field, Relationship

class CooperativeBase(SQLModel):
    society_name: str
    society_name_mr: Optional[str] = None
    society_name_hi: Optional[str] = None
    registration_number: str
    federation_id: Optional[str] = "MAH-PUNE-FED-2021"
    city: str = "Pune"
    district: str = "Pune"
    state: str = "Maharashtra"
    member_since: str = "June 2021"
    verified_workers_count: int = 42
    rating_avg: float = 4.85
    contact_phone: Optional[str] = "+91 20 2567 8900"
    logo_url: Optional[str] = "https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca"

class Cooperative(CooperativeBase, table=True):
    __tablename__ = "cooperatives"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

class CooperativeRead(CooperativeBase):
    id: int
    created_at: datetime
