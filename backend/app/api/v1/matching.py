from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from app.core.database import get_session
from app.models.worker import Worker, WorkerMatchItem
from app.models.cooperative import Cooperative
from app.services.fair_allocation_engine import FairAllocationEngine

router = APIRouter(prefix="/matching", tags=["Matching & Work Allocation"])

class FindWorkersRequest(BaseModel):
    customer_latitude: float = 18.4800  # Default Pune center
    customer_longitude: float = 73.8000
    service_category: str = "Plumbing"
    service_subcategory: str = "Tap & Faucet Repair"
    max_distance_km: float = 25.0
    min_rating: float = 0.0
    min_experience_years: int = 0
    only_available: bool = False
    sort_by: str = "MATCH_SCORE"  # MATCH_SCORE, NEAREST, PRICE_LOW, RATING_HIGH, EXPERIENCE_HIGH

class MatchingResponse(BaseModel):
    total_searched_workers: int
    matched_workers_count: int
    top_matches_count: int
    workers: List[WorkerMatchItem]

@router.post("/find-workers", response_model=MatchingResponse)
async def find_workers(
    req: FindWorkersRequest,
    session: AsyncSession = Depends(get_session)
):
    # Query all active workers
    workers_stmt = select(Worker)
    workers_res = await session.execute(workers_stmt)
    workers = workers_res.scalars().all()
    
    # Query cooperatives mapping
    coop_stmt = select(Cooperative)
    coop_res = await session.execute(coop_stmt)
    coops = coop_res.scalars().all()
    coops_by_id = {c.id: c for c in coops}
    
    verified_workers = [w for w in workers if getattr(w, "is_verified", False)]
    workers = verified_workers

    # Execute fair matching engine
    ranked_workers = FairAllocationEngine.rank_workers(
        workers=list(workers),
        coops_by_id=coops_by_id,
        customer_lat=req.customer_latitude,
        customer_lon=req.customer_longitude,
        service_category=req.service_category,
        service_subcategory=req.service_subcategory,
        max_distance_km=req.max_distance_km,
        min_rating=req.min_rating,
        min_experience=req.min_experience_years,
        only_available=req.only_available,
        sort_by=req.sort_by
    )
    
    top_picks = sum(1 for w in ranked_workers if w.match_score >= 85)
    
    return MatchingResponse(
        total_searched_workers=len(workers),
        matched_workers_count=len(ranked_workers),
        top_matches_count=top_picks,
        workers=ranked_workers
    )
