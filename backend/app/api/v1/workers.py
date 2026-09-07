from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from typing import Optional
from app.core.database import get_session
from app.models.worker import Worker, WorkerMatchItem
from app.models.cooperative import Cooperative
from app.services.fair_allocation_engine import FairAllocationEngine

router = APIRouter(prefix="/workers", tags=["Workers Profile"])

@router.get("/{worker_id}", response_model=WorkerMatchItem)
async def get_worker_profile(
    worker_id: int,
    customer_lat: float = Query(18.4800),
    customer_lon: float = Query(73.8000),
    session: AsyncSession = Depends(get_session)
):
    stmt = select(Worker).where(Worker.id == worker_id)
    res = await session.execute(stmt)
    worker = res.scalars().first()
    
    coop = None
    if worker and worker.cooperative_id:
        coop_stmt = select(Cooperative).where(Cooperative.id == worker.cooperative_id)
        coop_res = await session.execute(coop_stmt)
        coop = coop_res.scalars().first()
        
    if not worker:
        # Fallback to seeded demo worker for ID
        from seed_data import generate_synthetic_workers, generate_synthetic_cooperatives
        coops_list = generate_synthetic_cooperatives()
        workers_list = generate_synthetic_workers(coops_list)
        found = next((w for w in workers_list if (w.id or 1) == worker_id), workers_list[0])
        coop = coops_list[0]
        worker = found
        
    return FairAllocationEngine.compute_worker_match(
        worker=worker,
        coop=coop,
        customer_lat=customer_lat,
        customer_lon=customer_lon
    )
