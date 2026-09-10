from typing import Optional
from datetime import datetime
from sqlmodel import SQLModel, Field

class NotificationBase(SQLModel):
    user_id: str = Field(index=True)
    title: str
    message: str
    type: str = "SYSTEM"  # BOOKING_UPDATE, WALLET, RATING, SYSTEM
    related_id: Optional[str] = None
    is_read: bool = False

class Notification(NotificationBase, table=True):
    __tablename__ = "notifications"

    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)

class NotificationCreate(SQLModel):
    user_id: str
    title: str
    message: str
    type: Optional[str] = "SYSTEM"
    related_id: Optional[str] = None

class NotificationRead(NotificationBase):
    id: int
    created_at: datetime
