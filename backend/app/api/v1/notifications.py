from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from typing import List

from app.core.database import get_session
from app.models.notification import (
    Notification,
    NotificationCreate,
    NotificationRead,
)

router = APIRouter(prefix="/notifications", tags=["Notifications"])

@router.get("", response_model=List[NotificationRead])
async def get_user_notifications(
    user_id: str,
    session: AsyncSession = Depends(get_session)
):
    stmt = (
        select(Notification)
        .where(Notification.user_id == user_id)
        .order_by(Notification.created_at.desc())
    )
    result = await session.execute(stmt)
    notifications = result.scalars().all()

    # Seed initial welcome notification if none exist
    if not notifications:
        welcome = Notification(
            user_id=user_id,
            title="Welcome to SahayogSeva!",
            message="Your account is connected to our verified workers cooperative network. How can we help you today?",
            type="SYSTEM",
            is_read=False,
        )
        session.add(welcome)
        await session.commit()
        await session.refresh(welcome)
        return [welcome]

    return notifications

@router.post("", response_model=NotificationRead, status_code=status.HTTP_201_CREATED)
async def create_notification(
    req: NotificationCreate,
    session: AsyncSession = Depends(get_session)
):
    notification = Notification(
        user_id=req.user_id,
        title=req.title,
        message=req.message,
        type=req.type or "SYSTEM",
        related_id=req.related_id,
        is_read=False,
    )
    session.add(notification)
    await session.commit()
    await session.refresh(notification)
    return notification

@router.post("/{notification_id}/read", response_model=NotificationRead)
async def mark_notification_read(
    notification_id: int,
    session: AsyncSession = Depends(get_session)
):
    stmt = select(Notification).where(Notification.id == notification_id)
    result = await session.execute(stmt)
    notif = result.scalars().first()
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")

    notif.is_read = True
    session.add(notif)
    await session.commit()
    await session.refresh(notif)
    return notif

@router.post("/read-all", status_code=status.HTTP_200_OK)
async def mark_all_notifications_read(
    user_id: str,
    session: AsyncSession = Depends(get_session)
):
    stmt = select(Notification).where(Notification.user_id == user_id, Notification.is_read == False)
    result = await session.execute(stmt)
    for notif in result.scalars().all():
        notif.is_read = True
        session.add(notif)

    await session.commit()
    return {"success": True, "message": "All notifications marked as read"}
