from fastapi import APIRouter
from app.api.v1.ai import router as ai_router
from app.api.v1.matching import router as matching_router
from app.api.v1.workers import router as workers_router
from app.api.v1.bookings import router as bookings_router
from app.api.v1.auth import router as auth_router
from app.api.v1.payments import router as payments_router
from app.api.v1.ratings import router as ratings_router
from app.api.v1.invoices import router as invoices_router
from app.api.v1.jobs import router as jobs_router, legacy_router as legacy_jobs_router
from app.api.v1.cooperative import router as cooperative_router

api_router = APIRouter()
api_router.include_router(auth_router)
api_router.include_router(ai_router)
api_router.include_router(matching_router)
api_router.include_router(workers_router)
api_router.include_router(bookings_router)
api_router.include_router(payments_router)
api_router.include_router(ratings_router)
api_router.include_router(invoices_router)
api_router.include_router(jobs_router)
api_router.include_router(legacy_jobs_router)
api_router.include_router(cooperative_router)


