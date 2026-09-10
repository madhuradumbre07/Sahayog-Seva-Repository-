from typing import Optional
from datetime import datetime
from sqlmodel import SQLModel, Field

class CustomerAddressBase(SQLModel):
    customer_id: str = Field(index=True)
    title: str = "Home"  # e.g., "Home", "Office", "Parent's Place"
    address_line: str
    latitude: float = 18.4800
    longitude: float = 73.8000
    is_default: bool = False

class CustomerAddress(CustomerAddressBase, table=True):
    __tablename__ = "customer_addresses"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class CustomerAddressCreate(SQLModel):
    customer_id: str
    title: str = "Home"
    address_line: str
    latitude: Optional[float] = 18.4800
    longitude: Optional[float] = 73.8000
    is_default: Optional[bool] = False

class CustomerAddressRead(CustomerAddressBase):
    id: int
    created_at: datetime
