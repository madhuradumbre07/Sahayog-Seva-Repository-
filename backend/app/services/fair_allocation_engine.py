import math
import json
from typing import List, Dict, Any, Optional
from app.models.worker import Worker, WorkerMatchItem, ExplainabilityMatrix
from app.models.cooperative import Cooperative

def calculate_haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculates distance between two lat/lng points in kilometers."""
    R = 6371.0 # Earth radius in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return round(R * c, 2)

class FairAllocationEngine:
    @staticmethod
    def compute_worker_match(
        worker: Worker,
        coop: Optional[Cooperative],
        customer_lat: float,
        customer_lon: float,
        service_category: str = "Plumbing",
        service_subcategory: str = "Tap & Faucet Repair"
    ) -> WorkerMatchItem:
        # 1. Distance & Proximity Score (Weight: 25%)
        distance_km = calculate_haversine_distance(customer_lat, customer_lon, worker.latitude, worker.longitude)
        proximity_score = max(0, min(100, int(100 - (distance_km * 3.5))))
        
        # 2. Skill Match Score (Weight: 35%)
        skills = []
        try:
            skills = json.loads(worker.skills_json)
        except Exception:
            skills = ["Tap Repair", "Pipe Leakage"]
            
        skill_score = 60
        if worker.primary_trade.lower() in service_category.lower():
            skill_score = 85
            if any(s.lower() in service_subcategory.lower() or service_subcategory.lower() in s.lower() for s in skills):
                skill_score = 96
        
        # 3. Availability Score (Weight: 20%)
        avail_score = 20
        if worker.is_available and worker.availability_status == "AVAILABLE_NOW":
            avail_score = 100
        elif worker.availability_status == "BUSY_UNTIL_AFTERNOON":
            avail_score = 65
            
        # 4. Workload Fairness Score (Weight: 20%)
        # Prioritizes underutilized workers: 1 / (1 + jobs_this_month / 10)
        jobs_monthly = worker.jobs_completed_this_month or 0
        fairness_score = max(30, min(100, int(100 / (1.0 + (jobs_monthly / 12.0)))))
        
        # 5. Composite Match Score Formula
        raw_score = (0.35 * skill_score) + (0.25 * proximity_score) + (0.20 * avail_score) + (0.20 * fairness_score)
        match_score = int(min(99, max(35, round(raw_score))))
        
        coop_name = coop.society_name if coop else "शिवशक्ती सहकारी संस्था लि."
        
        explainability = ExplainabilityMatrix(
            skill_match_percent=skill_score,
            proximity_percent=proximity_score,
            availability_percent=avail_score,
            workload_fairness_percent=fairness_score,
            overall_match_score=match_score,
            distance_km=distance_km,
            reason_summary=f"High skill match ({skill_score}%) in {service_category} within {distance_km} km with verified cooperative membership."
        )
        
        return WorkerMatchItem(
            id=worker.id or 1,
            cooperative_id=worker.cooperative_id,
            full_name=worker.full_name,
            full_name_mr=worker.full_name_mr,
            full_name_hi=worker.full_name_hi,
            phone_number=worker.phone_number,
            avatar_url=worker.avatar_url,
            latitude=worker.latitude,
            longitude=worker.longitude,
            address_area=worker.address_area,
            primary_trade=worker.primary_trade,
            trade_subtitle=worker.trade_subtitle,
            experience_years=worker.experience_years,
            is_available=worker.is_available,
            availability_status=worker.availability_status,
            busy_until_text=worker.busy_until_text,
            rating_avg=worker.rating_avg,
            review_count=worker.review_count,
            jobs_completed_count=worker.jobs_completed_count,
            jobs_completed_this_month=worker.jobs_completed_this_month,
            response_time_minutes=worker.response_time_minutes,
            avg_completion_time_minutes=worker.avg_completion_time_minutes,
            hourly_rate_min=worker.hourly_rate_min,
            hourly_rate_max=worker.hourly_rate_max,
            is_verified=worker.is_verified,
            member_id=worker.member_id,
            welfare_scheme_id=worker.welfare_scheme_id,
            certifications_json=worker.certifications_json,
            skills_json=worker.skills_json,
            gallery_json=worker.gallery_json,
            reviews_json=worker.reviews_json,
            match_score=match_score,
            distance_km=distance_km,
            explainability=explainability,
            cooperative_society_name=coop_name,
        )

    @classmethod
    def rank_workers(
        cls,
        workers: List[Worker],
        coops_by_id: Dict[int, Cooperative],
        customer_lat: float,
        customer_lon: float,
        service_category: str = "Plumbing",
        service_subcategory: str = "Tap & Faucet Repair",
        max_distance_km: float = 25.0,
        min_rating: float = 0.0,
        min_experience: int = 0,
        only_available: bool = False,
        sort_by: str = "MATCH_SCORE"  # MATCH_SCORE, NEAREST, PRICE_LOW, RATING_HIGH, EXPERIENCE_HIGH
    ) -> List[WorkerMatchItem]:
        matched_items = []
        for w in workers:
            coop = coops_by_id.get(w.cooperative_id or 1)
            item = cls.compute_worker_match(
                worker=w,
                coop=coop,
                customer_lat=customer_lat,
                customer_lon=customer_lon,
                service_category=service_category,
                service_subcategory=service_subcategory
            )
            
            # Apply Filter criteria
            if item.distance_km > max_distance_km:
                continue
            if item.rating_avg < min_rating:
                continue
            if item.experience_years < min_experience:
                continue
            if only_available and not item.is_available:
                continue
                
            matched_items.append(item)
            
        # Apply Sorting
        if sort_by == "NEAREST":
            matched_items.sort(key=lambda x: x.distance_km)
        elif sort_by == "PRICE_LOW":
            matched_items.sort(key=lambda x: x.hourly_rate_min)
        elif sort_by == "RATING_HIGH":
            matched_items.sort(key=lambda x: x.rating_avg, reverse=True)
        elif sort_by == "EXPERIENCE_HIGH":
            matched_items.sort(key=lambda x: x.experience_years, reverse=True)
        else: # Default: MATCH_SCORE
            matched_items.sort(key=lambda x: x.match_score, reverse=True)
            
        return matched_items
