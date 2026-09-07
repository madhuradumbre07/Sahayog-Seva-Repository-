from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.core.database import get_session
from app.models.cooperative import Cooperative
from app.models.worker import Worker
from app.models.booking import Booking
from seed_data import generate_synthetic_cooperatives, generate_synthetic_workers

router = APIRouter(prefix="/cooperative", tags=["Cooperative Admin"])


class CooperativeKpiMetrics(BaseModel):
    total_workers: int = 48
    total_workers_delta: str = "+4 this week"
    active_jobs: int = 18
    active_jobs_delta: str = "+5 today"
    pending_requests: int = 12
    pending_requests_delta: str = "-3 from yesterday"
    completed_jobs: int = 96
    completed_jobs_delta: str = "+18 this week"
    total_earnings: int = 248000
    total_earnings_delta: str = "+17% this month"


class CooperativeJobRequestItem(BaseModel):
    id: str
    service_title_key: str
    service_category: str
    area: str
    time_ago_key: str
    time_ago_mins: int
    priority: str  # "URGENT", "NORMAL", "LOW"
    status: str    # "PENDING", "ASSIGNED"
    icon_name: str
    estimated_price_min: int
    estimated_price_max: int
    customer_name: str
    customer_phone: str


class ServiceDemandItem(BaseModel):
    category_key: str
    percentage: int
    color_hex: str


class ServiceDemandAnalytics(BaseModel):
    total_requests: int = 128
    breakdown: List[ServiceDemandItem] = Field(default_factory=list)


class WorkerAvailabilityBreakdown(BaseModel):
    available: int = 32
    on_job: int = 10
    on_leave: int = 4
    unavailable: int = 2


class WorkerAvailabilityAnalytics(BaseModel):
    total_workers: int = 48
    breakdown: WorkerAvailabilityBreakdown = Field(default_factory=WorkerAvailabilityBreakdown)


class EarningsWeeklyItem(BaseModel):
    week_label: str
    amount: int


class EarningsOverview(BaseModel):
    total_earnings: int = 248000
    growth_percentage: str = "+12%"
    filter_period_key: str = "thisMonth"
    subtitle_key: str = "platformDirectEarnings"
    weekly_breakdown: List[EarningsWeeklyItem] = Field(default_factory=list)


class RecentAssignmentItem(BaseModel):
    id: str
    worker_name: str
    worker_avatar: str
    job_type_key: str
    location: str
    status: str  # "ASSIGNED", "IN_PROGRESS", "COMPLETED"
    assigned_at: str
    assigned_at_key: Optional[str] = None


class CooperativeMemberItem(BaseModel):
    id: str
    name: str
    role_key: str  # "rolePresident", "roleSecretary", "roleTreasurer", "roleMember"
    role_title: str
    status: str    # "ACTIVE"
    avatar_url: Optional[str] = None


class UpcomingJobItem(BaseModel):
    id: str
    date_day: str
    date_month: str
    service_title_key: str
    location: str
    time: str
    status: str = "SCHEDULED"


class QuickActionItem(BaseModel):
    id: str
    title_key: str
    icon_name: str
    action_type: str


class CooperativeDashboardResponse(BaseModel):
    society_id: int = 1
    society_name: str = "Shivneri Seva Co-operative"
    society_name_mr: str = "शिवनेरी सेवा सहकारी संस्था"
    location: str = "Pune, Maharashtra"
    tagline_key: str = "heroOpportunitiesTagline"
    community_badge_key: str = "communityPillMotto"
    motto_badge_key: str = "cooperativeMottoBadge"
    notifications_count: int = 1
    kpi_metrics: CooperativeKpiMetrics = Field(default_factory=CooperativeKpiMetrics)
    job_requests: List[CooperativeJobRequestItem] = Field(default_factory=list)
    service_demand: ServiceDemandAnalytics = Field(default_factory=ServiceDemandAnalytics)
    worker_availability: WorkerAvailabilityAnalytics = Field(default_factory=WorkerAvailabilityAnalytics)
    earnings_overview: EarningsOverview = Field(default_factory=EarningsOverview)
    recent_assignments: List[RecentAssignmentItem] = Field(default_factory=list)
    cooperative_members: List[CooperativeMemberItem] = Field(default_factory=list)
    upcoming_jobs: List[UpcomingJobItem] = Field(default_factory=list)
    quick_actions: List[QuickActionItem] = Field(default_factory=list)


class AssignWorkerRequest(BaseModel):
    request_id: str
    worker_id: int
    notes: Optional[str] = None


class AssignWorkerResponse(BaseModel):
    success: bool
    request_id: str
    worker_id: int
    worker_name: str
    status: str = "ASSIGNED"
    message_key: str = "workerAssignedSuccess"


# In-memory overlay state for interactive assignments during session
_ASSIGNED_JOBS = {}


@router.get("/dashboard", response_model=CooperativeDashboardResponse)
async def get_cooperative_dashboard(
    cooperative_id: int = Query(default=1),
    session: AsyncSession = Depends(get_session),
):
    # Query database for cooperative entity or synthetic seed
    coop_stmt = select(Cooperative).where(Cooperative.id == cooperative_id)
    result = await session.execute(coop_stmt)
    coop = result.scalars().first()

    if not coop:
        coop_list = generate_synthetic_cooperatives()
        coop = coop_list[0] if coop_list else Cooperative(
            id=1,
            society_name="Shivneri Seva Co-operative",
            society_name_mr="शिवनेरी सेवा सहकारी संस्था",
            registration_number="SHSC-2021/1256",
            city="Pune",
            state="Maharashtra"
        )

    # Job Requests directly aligned with desktop & mobile design
    base_job_requests = [
        CooperativeJobRequestItem(
            id="REQ-PLUMB-01",
            service_title_key="servicePlumber",
            service_category="Plumbing Work",
            area="Kothrud, Pune",
            time_ago_key="timeAgo10Mins",
            time_ago_mins=10,
            priority="URGENT",
            status=_ASSIGNED_JOBS.get("REQ-PLUMB-01", "PENDING"),
            icon_name="plumbing",
            estimated_price_min=300,
            estimated_price_max=600,
            customer_name="Sandeep Patil",
            customer_phone="+91 98765 43210",
        ),
        CooperativeJobRequestItem(
            id="REQ-ELEC-02",
            service_title_key="serviceElectrical",
            service_category="Electrical Wiring",
            area="Baner, Pune",
            time_ago_key="timeAgo25Mins",
            time_ago_mins=25,
            priority="NORMAL",
            status=_ASSIGNED_JOBS.get("REQ-ELEC-02", "PENDING"),
            icon_name="electric_bolt",
            estimated_price_min=450,
            estimated_price_max=800,
            customer_name="Meera Joshi",
            customer_phone="+91 98221 54321",
        ),
        CooperativeJobRequestItem(
            id="REQ-AC-03",
            service_title_key="serviceAcRepair",
            service_category="AC Repair",
            area="Hinjawadi, Pune",
            time_ago_key="timeAgo1Hour",
            time_ago_mins=60,
            priority="NORMAL",
            status=_ASSIGNED_JOBS.get("REQ-AC-03", "PENDING"),
            icon_name="ac_unit",
            estimated_price_min=600,
            estimated_price_max=1200,
            customer_name="Amit Deshpande",
            customer_phone="+91 99701 23456",
        ),
        CooperativeJobRequestItem(
            id="REQ-CLEAN-04",
            service_title_key="serviceCleaning",
            service_category="House Cleaning",
            area="Wakad, Pune",
            time_ago_key="timeAgo2Hours",
            time_ago_mins=120,
            priority="LOW",
            status=_ASSIGNED_JOBS.get("REQ-CLEAN-04", "PENDING"),
            icon_name="cleaning_services",
            estimated_price_min=800,
            estimated_price_max=1500,
            customer_name="Sunita Kulkarni",
            customer_phone="+91 94230 98765",
        ),
        CooperativeJobRequestItem(
            id="REQ-CARP-05",
            service_title_key="serviceCarpentry",
            service_category="Carpentry Work",
            area="Aundh, Pune",
            time_ago_key="timeAgo3Hours",
            time_ago_mins=180,
            priority="NORMAL",
            status=_ASSIGNED_JOBS.get("REQ-CARP-05", "PENDING"),
            icon_name="carpenter",
            estimated_price_min=400,
            estimated_price_max=900,
            customer_name="Rajesh Shinde",
            customer_phone="+91 98500 11223",
        ),
    ]

    # Service Demand Donut breakdown
    service_demand = ServiceDemandAnalytics(
        total_requests=128,
        breakdown=[
            ServiceDemandItem(category_key="servicePlumbing", percentage=28, color_hex="#2563EB"),
            ServiceDemandItem(category_key="serviceElectrical", percentage=22, color_hex="#F59E0B"),
            ServiceDemandItem(category_key="serviceCleaning", percentage=16, color_hex="#10B981"),
            ServiceDemandItem(category_key="serviceAcRepair", percentage=12, color_hex="#06B6D4"),
            ServiceDemandItem(category_key="serviceCarpentry", percentage=10, color_hex="#EF4444"),
            ServiceDemandItem(category_key="serviceOthers", percentage=12, color_hex="#9CA3AF"),
        ]
    )

    # Worker Availability Gauge breakdown
    worker_avail = WorkerAvailabilityAnalytics(
        total_workers=48,
        breakdown=WorkerAvailabilityBreakdown(
            available=32,
            on_job=10,
            on_leave=4,
            unavailable=2,
        )
    )

    # Earnings Overview Bar Breakdown
    earnings = EarningsOverview(
        total_earnings=248000,
        growth_percentage="+12%",
        filter_period_key="thisMonth",
        subtitle_key="platformDirectEarnings",
        weekly_breakdown=[
            EarningsWeeklyItem(week_label="W1", amount=38000),
            EarningsWeeklyItem(week_label="W2", amount=48000),
            EarningsWeeklyItem(week_label="W3", amount=54000),
            EarningsWeeklyItem(week_label="W4", amount=72000),
        ]
    )

    # Recent Assignments List
    recent_assignments = [
        RecentAssignmentItem(
            id="ASG-01",
            worker_name="Rahul Patil",
            worker_avatar="https://images.unsplash.com/photo-1540569014015-19a7be504e3a",
            job_type_key="servicePlumbing",
            location="Kothrud",
            status="ASSIGNED",
            assigned_at="10:30 AM",
        ),
        RecentAssignmentItem(
            id="ASG-02",
            worker_name="Sneha Mane",
            worker_avatar="https://images.unsplash.com/photo-1534528741775-53994a69daeb",
            job_type_key="serviceElectrical",
            location="Baner",
            status="IN_PROGRESS",
            assigned_at="09:15 AM",
        ),
        RecentAssignmentItem(
            id="ASG-03",
            worker_name="Amit Shinde",
            worker_avatar="https://images.unsplash.com/photo-1506794778202-cad84cf45f1d",
            job_type_key="serviceAcRepair",
            location="Hinjawadi",
            status="COMPLETED",
            assigned_at="Yesterday",
            assigned_at_key="yesterdayLabel",
        ),
        RecentAssignmentItem(
            id="ASG-04",
            worker_name="Pooja Kadam",
            worker_avatar="https://images.unsplash.com/photo-1517841905240-472988babdf9",
            job_type_key="serviceCleaning",
            location="Wakad",
            status="ASSIGNED",
            assigned_at="Yesterday",
            assigned_at_key="yesterdayLabel",
        ),
        RecentAssignmentItem(
            id="ASG-05",
            worker_name="Vikram Jadhav",
            worker_avatar="https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
            job_type_key="serviceCarpentry",
            location="Aundh",
            status="IN_PROGRESS",
            assigned_at="2 Sept",
        ),
    ]

    # Co-operative Committee Members
    members = [
        CooperativeMemberItem(
            id="MEM-01",
            name="Ramesh Kulkarni",
            role_key="rolePresident",
            role_title="President",
            status="ACTIVE",
            avatar_url="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e",
        ),
        CooperativeMemberItem(
            id="MEM-02",
            name="Sneha Patil",
            role_key="roleSecretary",
            role_title="Secretary",
            status="ACTIVE",
            avatar_url="https://images.unsplash.com/photo-1534528741775-53994a69daeb",
        ),
        CooperativeMemberItem(
            id="MEM-03",
            name="Vikram Jadhav",
            role_key="roleTreasurer",
            role_title="Treasurer",
            status="ACTIVE",
            avatar_url="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
        ),
        CooperativeMemberItem(
            id="MEM-04",
            name="Pooja More",
            role_key="roleMember",
            role_title="Member",
            status="ACTIVE",
            avatar_url="https://images.unsplash.com/photo-1517841905240-472988babdf9",
        ),
    ]

    # Upcoming Jobs
    upcoming_jobs = [
        UpcomingJobItem(
            id="UP-01",
            date_day="04",
            date_month="Sep",
            service_title_key="serviceElectrical",
            location="Baner, Pune",
            time="11:00 AM",
            status="SCHEDULED",
        ),
        UpcomingJobItem(
            id="UP-02",
            date_day="04",
            date_month="Sep",
            service_title_key="serviceAcRepair",
            location="Hinjawadi, Pune",
            time="02:00 PM",
            status="SCHEDULED",
        ),
        UpcomingJobItem(
            id="UP-03",
            date_day="05",
            date_month="Sep",
            service_title_key="serviceCleaning",
            location="Wakad, Pune",
            time="10:00 AM",
            status="SCHEDULED",
        ),
        UpcomingJobItem(
            id="UP-04",
            date_day="05",
            date_month="Sep",
            service_title_key="servicePlumber",
            location="Kothrud, Pune",
            time="04:00 PM",
            status="SCHEDULED",
        ),
    ]

    # Quick Actions
    quick_actions = [
        QuickActionItem(
            id="QA-01",
            title_key="actionAddWorker",
            icon_name="group_add",
            action_type="ADD_WORKER",
        ),
        QuickActionItem(
            id="QA-02",
            title_key="actionManageAreas",
            icon_name="location_on",
            action_type="MANAGE_AREAS",
        ),
        QuickActionItem(
            id="QA-03",
            title_key="actionGenerateReport",
            icon_name="description",
            action_type="GENERATE_REPORT",
        ),
        QuickActionItem(
            id="QA-04",
            title_key="actionSendAnnouncement",
            icon_name="campaign",
            action_type="SEND_ANNOUNCEMENT",
        ),
    ]

    return CooperativeDashboardResponse(
        society_id=coop.id or 1,
        society_name=coop.society_name or "Shivneri Seva Co-operative",
        society_name_mr=coop.society_name_mr or "शिवनेरी सेवा सहकारी संस्था",
        location=f"{coop.city}, {coop.state}",
        tagline_key="heroOpportunitiesTagline",
        community_badge_key="communityPillMotto",
        motto_badge_key="cooperativeMottoBadge",
        notifications_count=1,
        kpi_metrics=CooperativeKpiMetrics(),
        job_requests=base_job_requests,
        service_demand=service_demand,
        worker_availability=worker_avail,
        earnings_overview=earnings,
        recent_assignments=recent_assignments,
        cooperative_members=members,
        upcoming_jobs=upcoming_jobs,
        quick_actions=quick_actions,
    )


@router.post("/assign", response_model=AssignWorkerResponse)
async def assign_worker(
    request: AssignWorkerRequest,
    session: AsyncSession = Depends(get_session),
):
    # Query worker from DB if available
    worker_stmt = select(Worker).where(Worker.id == request.worker_id)
    res = await session.execute(worker_stmt)
    worker = res.scalars().first()

    worker_name = worker.full_name if worker else "Rahul Patil"
    _ASSIGNED_JOBS[request.request_id] = "ASSIGNED"

    return AssignWorkerResponse(
        success=True,
        request_id=request.request_id,
        worker_id=request.worker_id,
        worker_name=worker_name,
        status="ASSIGNED",
        message_key="workerAssignedSuccess",
    )


@router.get("/workers", response_model=List[dict])
async def get_cooperative_workers(
    cooperative_id: int = Query(default=1),
    trade: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
):
    stmt = select(Worker)
    if trade:
        stmt = stmt.where(Worker.primary_trade == trade)
    res = await session.execute(stmt)
    workers = res.scalars().all()

    if not workers:
        coops = generate_synthetic_cooperatives()
        synthetic_workers = generate_synthetic_workers(coops)
        return [
            {
                "id": w.id,
                "name": w.full_name,
                "trade": w.primary_trade,
                "rating": w.rating_avg,
                "is_available": w.is_available,
                "phone": w.phone_number,
                "avatar_url": w.avatar_url,
            }
            for w in synthetic_workers[:10]
        ]

    return [
        {
            "id": w.id,
            "name": w.full_name,
            "trade": w.primary_trade,
            "rating": w.rating_avg,
            "is_available": w.is_available,
            "phone": w.phone_number,
            "avatar_url": w.avatar_url,
        }
        for w in workers[:10]
    ]
