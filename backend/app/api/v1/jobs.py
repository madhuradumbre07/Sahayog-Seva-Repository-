from datetime import datetime
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.core.database import get_session
from app.models.job import (
    JobRequestDetail,
    JobActionResponse,
    JobPriority,
    JobRequestStatus,
    WorkerJobRecord,
)

router = APIRouter(prefix="/worker/jobs", tags=["Worker Jobs"])
legacy_router = APIRouter(prefix="/jobs", tags=["Worker Jobs Legacy"])


class JobStatusUpdate(BaseModel):
    status: JobRequestStatus


class OtpVerificationRequest(BaseModel):
    otp: str


def _detail(record: WorkerJobRecord) -> JobRequestDetail:
    return JobRequestDetail.from_record(record)


async def _get_record(job_id: str, session: AsyncSession) -> WorkerJobRecord:
    result = await session.execute(select(WorkerJobRecord).where(WorkerJobRecord.id == job_id))
    record = result.scalars().first()
    if record is None:
        raise HTTPException(status_code=404, detail="Worker job was not found")
    return record


async def _seed_sample_jobs(session: AsyncSession) -> None:
    result = await session.execute(select(WorkerJobRecord).limit(1))
    if result.scalars().first() is not None:
        return
    session.add(WorkerJobRecord.from_detail(JobRequestDetail()))
    session.add(WorkerJobRecord.from_detail(JobRequestDetail(id="REQ-250531-0179", priority=JobPriority.MEDIUM)))
    await session.commit()


@router.get("/requests/pending", response_model=List[JobRequestDetail])
async def get_pending_job_requests(session: AsyncSession = Depends(get_session)):
    await _seed_sample_jobs(session)
    result = await session.execute(
        select(WorkerJobRecord).where(
            WorkerJobRecord.status.in_([JobRequestStatus.PENDING, JobRequestStatus.EXPIRING])
        )
    )
    return [_detail(record) for record in result.scalars().all()]


@router.get("/{job_id}", response_model=JobRequestDetail)
async def get_job_details(job_id: str, session: AsyncSession = Depends(get_session)):
    return _detail(await _get_record(job_id, session))


@router.patch("/{job_id}/status", response_model=JobActionResponse)
async def update_job_status(
    job_id: str,
    update: JobStatusUpdate,
    session: AsyncSession = Depends(get_session),
):
    record = await _get_record(job_id, session)
    allowed = {
        JobRequestStatus.ACCEPTED: {JobRequestStatus.PENDING, JobRequestStatus.EXPIRING},
        JobRequestStatus.NAVIGATING: {JobRequestStatus.ACCEPTED},
        JobRequestStatus.ARRIVED_OTP: {JobRequestStatus.NAVIGATING},
        JobRequestStatus.IN_PROGRESS: {JobRequestStatus.ARRIVED_OTP},
        JobRequestStatus.COMPLETED: {JobRequestStatus.IN_PROGRESS},
        JobRequestStatus.REJECTED: {JobRequestStatus.PENDING, JobRequestStatus.EXPIRING},
    }
    if update.status not in allowed or record.status not in allowed[update.status]:
        raise HTTPException(
            status_code=409,
            detail=f"Cannot transition {record.status} to {update.status}",
        )
    record.status = update.status
    record.updated_at = datetime.utcnow()
    await session.commit()
    return JobActionResponse(
        success=True,
        job_id=job_id,
        status=record.status,
        message_key="jobStatusUpdated",
    )


@router.post("/{job_id}/verify-otp", response_model=JobActionResponse)
async def verify_job_otp(
    job_id: str,
    request: OtpVerificationRequest,
    session: AsyncSession = Depends(get_session),
):
    record = await _get_record(job_id, session)
    if record.status != JobRequestStatus.ARRIVED_OTP:
        raise HTTPException(status_code=409, detail="Job is not awaiting doorstep OTP")
    if request.otp != record.otp_code:
        raise HTTPException(status_code=400, detail="Invalid OTP")
    record.status = JobRequestStatus.IN_PROGRESS
    record.updated_at = datetime.utcnow()
    await session.commit()
    return JobActionResponse(
        success=True,
        job_id=job_id,
        status=record.status,
        message_key="otpVerifiedSuccess",
    )


async def _ensure_legacy_record(job_id: str, session: AsyncSession) -> WorkerJobRecord:
    try:
        return await _get_record(job_id, session)
    except HTTPException as error:
        if error.status_code != 404:
            raise
        record = WorkerJobRecord.from_detail(JobRequestDetail(id=job_id))
        session.add(record)
        await session.commit()
        return record


@legacy_router.get("/requests/pending", response_model=List[JobRequestDetail])
async def legacy_pending(session: AsyncSession = Depends(get_session)):
    return await get_pending_job_requests(session)


@legacy_router.get("/{job_id}", response_model=JobRequestDetail)
async def legacy_details(job_id: str, session: AsyncSession = Depends(get_session)):
    return _detail(await _ensure_legacy_record(job_id, session))


@legacy_router.post("/{job_id}/accept", response_model=JobActionResponse)
async def legacy_accept(job_id: str, session: AsyncSession = Depends(get_session)):
    record = await _ensure_legacy_record(job_id, session)
    if record.status not in (JobRequestStatus.PENDING, JobRequestStatus.EXPIRING):
        raise HTTPException(status_code=409, detail="Job is no longer available")
    record.status = JobRequestStatus.ACCEPTED
    record.updated_at = datetime.utcnow()
    await session.commit()
    return JobActionResponse(success=True, job_id=job_id, status=record.status, message_key="jobAcceptedSuccessToast")


@legacy_router.post("/{job_id}/reject", response_model=JobActionResponse)
async def legacy_reject(job_id: str, session: AsyncSession = Depends(get_session)):
    record = await _ensure_legacy_record(job_id, session)
    record.status = JobRequestStatus.REJECTED
    record.updated_at = datetime.utcnow()
    await session.commit()
    return JobActionResponse(success=True, job_id=job_id, status=record.status, message_key="jobRejectedSuccessToast")
