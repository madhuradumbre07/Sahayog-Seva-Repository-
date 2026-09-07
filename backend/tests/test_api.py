import pytest
from app.services.ai_problem_parser import AiProblemParserService
from app.services.fair_allocation_engine import FairAllocationEngine
from app.models.worker import Worker
from app.models.cooperative import Cooperative

def test_ai_problem_parser():
    res_mr = AiProblemParserService.parse_problem("किचनच्या नळातून पाणी गळत आहे", detected_lang="mr")
    assert res_mr.service_category == "Plumbing"
    assert res_mr.confidence_score >= 0.90
    assert "Tap Repair" in res_mr.suggested_skills

    res_elec = AiProblemParserService.parse_problem("हॉलचा पंखा चालू होत नाही आहे", detected_lang="mr")
    assert res_elec.service_category == "Electrician"

def test_fair_allocation_match_score():
    worker = Worker(
        id=1,
        full_name="Rahul Sharma",
        phone_number="+91 98220 12345",
        latitude=18.4850,
        longitude=73.8050,
        primary_trade="Plumber",
        is_available=True,
        availability_status="AVAILABLE_NOW",
        jobs_completed_this_month=6,
        skills_json='["Tap Repair", "Pipe Leakage"]'
    )
    coop = Cooperative(id=1, society_name="शिवशक्ती कामगार सहकारी संस्था लि.", registration_number="SHSC-2021/1256")
    
    # Customer at Warje (18.4800, 73.8000) -> approx 0.76 km
    match_item = FairAllocationEngine.compute_worker_match(
        worker=worker,
        coop=coop,
        customer_lat=18.4800,
        customer_lon=73.8000,
        service_category="Plumbing",
        service_subcategory="Tap & Faucet Repair"
    )
    
    assert match_item.match_score >= 85
    assert match_item.explainability.skill_match_percent >= 90
    assert match_item.explainability.proximity_percent >= 90
    assert match_item.distance_km < 2.0
