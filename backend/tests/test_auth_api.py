import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.core.database import init_db

@pytest.mark.anyio
async def test_auth_registration_and_profile():
    await init_db()
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # Register a worker
        reg_payload = {
            "full_name": "Sanjay Patil",
            "mobile": "9876543219",
            "email": "sanjay.patil@example.com",
            "password": "SecurePassword123!",
            "role": "worker",
            "location": "Pune, Maharashtra",
            "work_category": "Electrician",
            "is_registered": True
        }
        res = await client.post("/api/v1/auth/register", json=reg_payload)
        assert res.status_code in [200, 201, 409]

        # Get user profile
        profile_res = await client.get("/api/v1/auth/profile/9876543219?role=worker")
        assert profile_res.status_code == 200
        data = profile_res.json()
        assert data["full_name"] == "Sanjay Patil"
        assert data["mobile"] == "9876543219"
        assert data["is_registered"] is True

        # Update user profile
        update_payload = {
            "full_name": "Sanjay V. Patil",
            "email": "sanjay.v.patil@example.com",
            "location": "Kothrud, Pune"
        }
        update_res = await client.put("/api/v1/auth/profile/9876543219?role=worker", json=update_payload)
        assert update_res.status_code == 200
        updated_data = update_res.json()
        assert updated_data["full_name"] == "Sanjay V. Patil"
        assert updated_data["location"] == "Kothrud, Pune"
