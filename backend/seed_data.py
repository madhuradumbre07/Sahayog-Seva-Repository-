import asyncio
import json
import random
from typing import List
from sqlmodel import select
from app.core.database import async_session_factory, init_db
from app.models.cooperative import Cooperative
from app.models.worker import Worker

PUNE_AREAS = [
    ("Kothrud, Pune", 18.5074, 73.8077),
    ("Warje, Pune", 18.4800, 73.8000),
    ("Shivajinagar, Pune", 18.5314, 73.8446),
    ("Hadapsar, Pune", 18.5089, 73.9259),
    ("Baner, Pune", 18.5590, 73.7868),
    ("Wakad, Pune", 18.5987, 73.7688),
    ("Kharadi, Pune", 18.5515, 73.9349),
    ("Katraj, Pune", 18.4575, 73.8677),
    ("Aundh, Pune", 18.5602, 73.8031),
    ("Viman Nagar, Pune", 18.5679, 73.9143),
]

SOCIETIES = [
    ("शिवशक्ती कामगार सहकारी संस्था लि.", "Shivshakti Workers Cooperative Society Ltd.", "SHSC-2021/1256"),
    ("सहयोग श्रमजीवी सहकारी पतसंस्था", "Sahayog Shramjeevi Cooperative Credit Society", "SSCS-2019/8421"),
    ("महाराष्ट्र कुशल तंत्रज्ञ सहकारी संस्था", "Maharashtra Skilled Technicians Cooperative", "MSTC-2020/4512"),
    ("पुणे शहर सेवा कामगार फेडरेशन", "Pune City Service Workers Federation", "PCSW-2018/9934"),
    ("समता गृहोपयोगी सेवा सहकारी मंडळ", "Samata Household Services Cooperative", "SHSC-2022/3310"),
]

WORKER_NAMES = [
    ("राहुल शर्मा", "Rahul Sharma", "Plumber", "Piping & Leakage Specialist", "https://images.unsplash.com/photo-1540569014015-19a7be504e3a"),
    ("श्रीकांत पाटील", "Shrikant Patil", "Plumber", "Tap & Drain Specialist", "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d"),
    ("संजय शिंदे", "Sanjay Shinde", "Plumber", "Master Pipe Fitter", "https://images.unsplash.com/photo-1500648767791-00dcc994a43e"),
    ("प्रकाश मोरे", "Prakash More", "Plumber", "Bathroom Fitting Expert", "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e"),
    ("सचिन कदम", "Sachin Kadam", "Plumber", "Leak Detection & Repair", "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7"),
    ("अमित जोशी", "Amit Joshi", "Electrician", "Wiring & Safety Expert", "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d"),
    ("गणेश देशमुख", "Ganesh Deshmukh", "Electrician", "Home Appliance Specialist", "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61"),
    ("सुनील पवार", "Sunil Pawar", "Deep Cleaning", "Tank & Floor Sanitation", "https://images.unsplash.com/photo-1534528741775-53994a69daeb"),
    ("मंगेश गायकवाड", "Mangesh Gaikwad", "Painter", "Interior Wall Specialist", "https://images.unsplash.com/photo-1517841905240-472988babdf9"),
    ("दीपक सावंत", "Deepak Sawant", "Appliance Repair", "Geyser & AC Technician", "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6"),
]

def generate_synthetic_cooperatives() -> List[Cooperative]:
    coops = []
    for i, (name_mr, name_en, reg) in enumerate(SOCIETIES):
        coop = Cooperative(
            id=i + 1,
            society_name=name_mr,
            society_name_mr=name_mr,
            society_name_hi=name_mr,
            registration_number=reg,
            federation_id=f"MAH-PUNE-FED-{2018+i}",
            city="Pune",
            district="Pune",
            state="Maharashtra",
            member_since=f"June {2018+i}",
            verified_workers_count=random.randint(25, 80),
            rating_avg=round(random.uniform(4.7, 4.95), 2),
            contact_phone=f"+91 20 256{i} {8900+i}",
            logo_url="https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca"
        )
        coops.append(coop)
    return coops

def generate_synthetic_workers(cooperatives: List[Cooperative]) -> List[Worker]:
    workers = []
    for i in range(50):
        name_tuple = WORKER_NAMES[i % len(WORKER_NAMES)]
        area_tuple = PUNE_AREAS[i % len(PUNE_AREAS)]
        coop = cooperatives[i % len(cooperatives)]
        
        # Add small jitter to coordinates (within 1-3km)
        lat_jitter = round(area_tuple[1] + random.uniform(-0.015, 0.015), 5)
        lon_jitter = round(area_tuple[2] + random.uniform(-0.015, 0.015), 5)
        
        name_mr = name_tuple[0]
        if i >= 10:
            name_mr = f"{name_tuple[0]} {chr(65 + (i % 26))}"
            
        is_avail = random.choice([True, True, True, False])
        avail_status = "AVAILABLE_NOW" if is_avail else random.choice(["BUSY_UNTIL_AFTERNOON", "OFFLINE"])
        busy_text = "आज दुपारी 4:00 PM पर्यंत व्यस्त" if avail_status == "BUSY_UNTIL_AFTERNOON" else None
        
        w = Worker(
            id=i + 1,
            cooperative_id=coop.id or ((i % len(cooperatives)) + 1),
            full_name=name_tuple[1] if i % 2 == 1 else name_mr,
            full_name_mr=name_mr,
            full_name_hi=name_mr,
            phone_number=f"+91 98{random.randint(10, 99)} {random.randint(10000, 99999)}",
            avatar_url=name_tuple[4],
            latitude=lat_jitter,
            longitude=lon_jitter,
            address_area=area_tuple[0],
            primary_trade=name_tuple[2],
            trade_subtitle=name_tuple[3],
            experience_years=random.randint(3, 12),
            is_available=is_avail,
            availability_status=avail_status,
            busy_until_text=busy_text,
            rating_avg=round(random.uniform(4.5, 4.95), 1),
            review_count=random.randint(45, 230),
            jobs_completed_count=random.randint(120, 650),
            jobs_completed_this_month=random.randint(4, 28),
            response_time_minutes=random.randint(8, 25),
            avg_completion_time_minutes=random.randint(25, 45),
            hourly_rate_min=random.choice([200, 250, 300]),
            hourly_rate_max=random.choice([450, 500, 600]),
            is_verified=True,
            member_id=f"SHSC-{random.randint(10000, 99999)}",
            welfare_scheme_id=f"ESHRAM-MH-{random.randint(100000, 999999)}",
            certifications_json=json.dumps([
                {"title": "Plumbing Skill (NSDC Certified)", "issuer": "NSDC India"},
                {"title": "Water Safety (Government Certified)", "issuer": "Govt of Maharashtra"},
                {"title": "CPR & First Aid Certified", "issuer": "Red Cross Society"}
            ]),
            skills_json=json.dumps([
                "Tap Repair", "Pipe Leakage", "Bathroom Fitting", "Flush Repair", "PVC Pipe Work", "Water Tank Cleaning", "Drain Cleaning"
            ]),
            gallery_json=json.dumps([
                "https://images.unsplash.com/photo-1585704032915-c3400ca199e7",
                "https://images.unsplash.com/photo-1607472586893-edb57bdc0e39",
                "https://images.unsplash.com/photo-1581244277943-fe4a9c777189",
                "https://images.unsplash.com/photo-1504307651254-35680f356dfd"
            ]),
            reviews_json=json.dumps([
                {"author": "प्रिया कुलकर्णी", "rating": 5.0, "comment": "वेळेवर आले आणि नळ पटकन दुरुस्त केला. खूप नम्र आणि कुशल कामगार!", "date": "2 दिवसांपूर्वी"},
                {"author": "अमित जोशी", "rating": 4.8, "comment": "Excellent work with zero extra charges. Cooperative guarantee gives great peace of mind.", "date": "1 आठवड्यापूर्वी"},
                {"author": "सचिन कदम", "rating": 4.9, "comment": "पाईप गळती पूर्णपणे थांबवली. काम अतिशय स्वच्छ केले.", "date": "2 आठवड्यांपूर्वी"}
            ])
        )
        workers.append(w)
    return workers

async def seed_database():
    print("🌱 Initializing Database Schema...")
    await init_db()
    
    async with async_session_factory() as session:
        # Check if already seeded
        res = await session.execute(select(Worker))
        existing = res.scalars().all()
        if existing:
            print(f"✓ Database already contains {len(existing)} workers.")
            return
            
        print("🌱 Seeding 5 Cooperatives...")
        coops = generate_synthetic_cooperatives()
        for c in coops:
            session.add(c)
        await session.commit()
        
        # Refresh to get IDs
        res_coops = await session.execute(select(Cooperative))
        saved_coops = res_coops.scalars().all()
        
        print("🌱 Seeding 50 Synthetic Cooperative Workers...")
        workers = generate_synthetic_workers(list(saved_coops))
        for w in workers:
            session.add(w)
        await session.commit()
        
        print(f"✓ Successfully seeded {len(saved_coops)} cooperatives and {len(workers)} workers!")

if __name__ == "__main__":
    asyncio.run(seed_database())
