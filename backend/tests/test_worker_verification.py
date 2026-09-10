import pytest
from httpx import AsyncClient, ASGITransport
from sqlmodel import select
from app.main import app
from app.core.database import init_db, get_session
from app.models.worker_profile import WorkerProfile


@pytest.fixture(scope="module")
def anyio_backend():
    return "asyncio"


@pytest.fixture(scope="module", autouse=True)
async def setup_database():
    await init_db()


async def cleanup_user(user_id: str):
    async for session in get_session():
        stmt = select(WorkerProfile).where(WorkerProfile.user_id == user_id)
        res = await session.execute(stmt)
        for p in res.scalars().all():
            await session.delete(p)
        await session.commit()
        break


@pytest.mark.anyio
async def test_successful_worker_registration():
    test_user_id = "WORKER-TEST-SUCCESS-01"
    await cleanup_user(test_user_id)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {
            "user_id": test_user_id,
            "full_name": "Rajesh Kumar",
            "mobile": "9876543210",
            "skills": ["Plumbing", "Sanitaryware"],
            "experience_years": 5,
            "cooperative_id": 1,
            "certifications": ["NSDC Plumbing Level 2"]
        }
        res = await client.post("/api/v1/workers/register", json=payload)
        assert res.status_code == 201
        data = res.json()
        assert data["user_id"] == test_user_id
        assert data["full_name"] == "Rajesh Kumar"
        assert data["verification_status"] == "PENDING"
        assert "Plumbing" in data["skills"]


@pytest.mark.anyio
async def test_duplicate_worker_registration():
    test_user_id = "WORKER-TEST-DUP-01"
    await cleanup_user(test_user_id)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {
            "user_id": test_user_id,
            "full_name": "Anil Sharma",
            "mobile": "9812345678",
            "skills": ["Electrical"],
            "experience_years": 3
        }
        res1 = await client.post("/api/v1/workers/register", json=payload)
        assert res1.status_code == 201

        res2 = await client.post("/api/v1/workers/register", json=payload)
        assert res2.status_code == 400
        assert "already registered" in res2.json()["detail"]


@pytest.mark.anyio
async def test_worker_registration_input_validations():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        invalid_payload = {
            "user_id": "WORKER-TEST-INVALID-01",
            "full_name": "",
            "mobile": "123",
            "experience_years": -1
        }
        res = await client.post("/api/v1/workers/register", json=invalid_payload)
        assert res.status_code == 400


@pytest.mark.anyio
async def test_worker_initial_pending_status_and_queue():
    test_user_id = "WORKER-TEST-PENDING-01"
    await cleanup_user(test_user_id)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {
            "user_id": test_user_id,
            "full_name": "Suresh Verma",
            "mobile": "9123456789",
            "skills": ["Carpentry"],
            "experience_years": 2
        }
        reg_res = await client.post("/api/v1/workers/register", json=payload)
        assert reg_res.status_code == 201
        assert reg_res.json()["verification_status"] == "PENDING"

        pending_res = await client.get("/api/v1/workers/pending")
        assert pending_res.status_code == 200
        pending_list = pending_res.json()
        assert any(w["user_id"] == test_user_id for w in pending_list)


@pytest.mark.anyio
async def test_get_worker_profile():
    test_user_id = "WORKER-TEST-GET-01"
    await cleanup_user(test_user_id)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {
            "user_id": test_user_id,
            "full_name": "Pooja Hegde",
            "mobile": "9988776655",
            "skills": ["Painting"],
            "experience_years": 4
        }
        reg_res = await client.post("/api/v1/workers/register", json=payload)
        assert reg_res.status_code == 201

        get_res = await client.get(f"/api/v1/workers/{test_user_id}")
        assert get_res.status_code == 200
        data = get_res.json()
        assert data["user_id"] == test_user_id
        assert data["full_name"] == "Pooja Hegde"
        assert "Painting" in data["skills"]


@pytest.mark.anyio
async def test_admin_verification_lifecycle_under_review_verified_and_rejected():
    test_user_id_1 = "WORKER-TEST-TRANS-APPROVED"
    test_user_id_2 = "WORKER-TEST-TRANS-REJECTED"
    await cleanup_user(test_user_id_1)
    await cleanup_user(test_user_id_2)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Worker 1: PENDING -> UNDER_REVIEW -> VERIFIED
        await client.post("/api/v1/workers/register", json={
            "user_id": test_user_id_1,
            "full_name": "Vijay Sethu",
            "mobile": "9876543211",
            "skills": ["Tile Fitting"],
            "experience_years": 6
        })

        review_res = await client.patch(
            f"/api/v1/workers/{test_user_id_1}/verify",
            json={"verification_status": "UNDER_REVIEW"},
            headers={"X-User-Role": "admin"}
        )
        assert review_res.status_code == 200
        assert review_res.json()["verification_status"] == "UNDER_REVIEW"

        verify_res = await client.patch(
            f"/api/v1/workers/{test_user_id_1}/verify",
            json={"verification_status": "VERIFIED"},
            headers={"X-User-Role": "admin"}
        )
        assert verify_res.status_code == 200
        assert verify_res.json()["verification_status"] == "VERIFIED"

        # Worker 2: PENDING -> REJECTED with reason
        await client.post("/api/v1/workers/register", json={
            "user_id": test_user_id_2,
            "full_name": "Karan Singh",
            "mobile": "9876543212",
            "skills": ["Cleaning"],
            "experience_years": 1
        })

        reject_res = await client.patch(
            f"/api/v1/workers/{test_user_id_2}/verify",
            json={
                "verification_status": "REJECTED",
                "rejection_reason": "Incomplete trade certification documents"
            },
            headers={"X-User-Role": "admin"}
        )
        assert reject_res.status_code == 200
        data = reject_res.json()
        assert data["verification_status"] == "REJECTED"
        assert data["rejection_reason"] == "Incomplete trade certification documents"


@pytest.mark.anyio
async def test_invalid_status_transition():
    test_user_id = "WORKER-TEST-INVALID-TRANS"
    await cleanup_user(test_user_id)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        await client.post("/api/v1/workers/register", json={
            "user_id": test_user_id,
            "full_name": "Rohan Mehra",
            "mobile": "9765432109",
            "skills": ["Gardening"],
            "experience_years": 2
        })

        res = await client.patch(
            f"/api/v1/workers/{test_user_id}/verify",
            json={"verification_status": "SUPER_VERIFIED"},
            headers={"X-User-Role": "admin"}
        )
        assert res.status_code == 400
        assert "Invalid status" in res.json()["detail"]


@pytest.mark.anyio
async def test_non_admin_access_forbidden():
    test_user_id = "WORKER-TEST-NON-ADMIN"
    await cleanup_user(test_user_id)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        await client.post("/api/v1/workers/register", json={
            "user_id": test_user_id,
            "full_name": "Sneha Roy",
            "mobile": "9654321098",
            "skills": ["Pest Control"],
            "experience_years": 3
        })

        res = await client.patch(
            f"/api/v1/workers/{test_user_id}/verify",
            json={"verification_status": "VERIFIED"},
            headers={"X-User-Role": "customer"}
        )
        assert res.status_code == 403
        assert "Forbidden" in res.json()["detail"]


@pytest.mark.anyio
async def test_worker_self_verification_attempt_forbidden():
    test_user_id = "WORKER-TEST-SELF-VERIFY"
    await cleanup_user(test_user_id)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        await client.post("/api/v1/workers/register", json={
            "user_id": test_user_id,
            "full_name": "Manish Paul",
            "mobile": "9543210987",
            "skills": ["Roofing"],
            "experience_years": 5
        })

        res = await client.patch(
            f"/api/v1/workers/{test_user_id}/verify",
            json={"verification_status": "VERIFIED"},
            headers={"X-User-Role": "worker"}
        )
        assert res.status_code == 403
        assert "Forbidden" in res.json()["detail"]


@pytest.mark.anyio
async def test_update_worker_profile():
    test_user_id = "WORKER-TEST-UPDATE-01"
    await cleanup_user(test_user_id)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        await client.post("/api/v1/workers/register", json={
            "user_id": test_user_id,
            "full_name": "Sunil Shetty",
            "mobile": "9432109876",
            "skills": ["Masonry"],
            "experience_years": 4
        })

        put_payload = {
            "full_name": "Sunil V. Shetty",
            "email": "sunil.shetty@example.com",
            "location": "Baner, Pune",
            "skills": ["Masonry", "Plastering"]
        }
        res = await client.put(f"/api/v1/workers/{test_user_id}", json=put_payload)
        assert res.status_code == 200
        data = res.json()
        assert data["full_name"] == "Sunil V. Shetty"
        assert data["email"] == "sunil.shetty@example.com"
        assert data["location"] == "Baner, Pune"
        assert "Plastering" in data["skills"]
