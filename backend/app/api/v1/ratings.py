from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select, func

from app.core.database import get_session
from app.models.payment_rating import RatingSubmitRequest, RatingSubmitResponse, WorkerReview
from app.models.worker import Worker
from app.models.worker_profile import WorkerProfile

router = APIRouter(prefix="/ratings", tags=["Ratings"])


@router.post("/submit", response_model=RatingSubmitResponse)
async def submit_rating(req: RatingSubmitRequest, session: AsyncSession = Depends(get_session)):
    if req.rating < 1.0 or req.rating > 5.0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Rating must be between 1.0 and 5.0.",
        )

    review = WorkerReview(
        booking_id=req.booking_id,
        worker_id=req.worker_id,
        rating=req.rating,
        review_text=req.review_text or "",
    )
    session.add(review)
    await session.commit()

    agg = await session.execute(
        select(func.avg(WorkerReview.rating), func.count(WorkerReview.id)).where(
            WorkerReview.worker_id == req.worker_id
        )
    )
    avg_val, count_val = agg.one()
    new_avg = round(float(avg_val or req.rating), 2)
    new_count = int(count_val or 1)

    wres = await session.execute(select(Worker).where(Worker.id == req.worker_id))
    worker = wres.scalars().first()
    if worker:
        worker.rating_avg = new_avg
        worker.review_count = new_count
        session.add(worker)
        if worker.user_id:
            pres = await session.execute(select(WorkerProfile).where(WorkerProfile.user_id == worker.user_id))
            profile = pres.scalars().first()
            if profile:
                profile.rating_avg = new_avg
                profile.review_count = new_count
                session.add(profile)
    await session.commit()

    return RatingSubmitResponse(
        status="RATED",
        booking_id=req.booking_id,
        worker_id=req.worker_id,
        rating=req.rating,
        review_text=req.review_text or "",
        updated_average_rating=new_avg,
        total_reviews=new_count,
        message="Rating and review submitted successfully",
    )
