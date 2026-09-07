from typing import Optional
from datetime import datetime
from sqlmodel import SQLModel, Field

class UserBase(SQLModel):
    full_name: str
    mobile: str = Field(index=True)
    email: Optional[str] = None
    role: str = Field(description="Role: worker, customer, contractor, cooperative")
    location: str
    is_registered: bool = Field(default=True)
    
    # Role specific fields
    work_category: Optional[str] = None
    organization_name: Optional[str] = None
    company_name: Optional[str] = None
    gst_number: Optional[str] = None
    cooperative_name: Optional[str] = None
    representative_name: Optional[str] = None
    registration_number: Optional[str] = None

class User(UserBase, table=True):
    __tablename__ = "users"

    id: Optional[int] = Field(default=None, primary_key=True)
    hashed_password: str
    is_active: bool = Field(default=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class UserCreate(UserBase):
    password: str

class UserUpdate(SQLModel):
    full_name: Optional[str] = None
    email: Optional[str] = None
    location: Optional[str] = None
    work_category: Optional[str] = None
    organization_name: Optional[str] = None
    company_name: Optional[str] = None
    gst_number: Optional[str] = None
    cooperative_name: Optional[str] = None
    representative_name: Optional[str] = None
    registration_number: Optional[str] = None

class UserRead(UserBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None
