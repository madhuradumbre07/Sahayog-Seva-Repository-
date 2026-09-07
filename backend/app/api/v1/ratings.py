from fastapi import APIRouter, HTTPException, status
from app.models.payment_rating import RatingSubmitRequest, RatingSubmitResponse

router = APIRouter(prefix="/ratings", tags=["Ratings"])

@router.post("/submit", response_model=RatingSubmitResponse)
async def submit_rating(req: RatingSubmitRequest):
    if req.rating < 1.0 or req.rating > 5.0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Rating must be between 1.0 and 5.0."
        )
    
    # Calculate simulated updated rating
    current_avg = 4.8
    current_count = 156
    new_count = current_count + 1
    new_avg = round(((current_avg * current_count) + req.rating) / new_count, 2)
    
    return RatingSubmitResponse(
        status="RATED",
        booking_id=req.booking_id,
        worker_id=req.worker_id,
        rating=req.rating,
        review_text=req.review_text or "",
        updated_average_rating=new_avg,
        total_reviews=new_count,
        message="Rating and review submitted successfully"
    )
