from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def _create_job(worker_user_id="WORKER-JOB-TEST", **overrides):
    payload = {
        "worker_user_id": worker_user_id,
        "customer_id": "CUST-TEST",
        "customer_name": "Test Customer",
        "service_category": "Plumbing",
        "service_subcategory": "Tap Repair",
        "problem_description": "Leaking tap",
        "address_line": "Warje, Pune",
        "total_min": 250,
        "total_max": 500,
        **overrides,
    }
    response = client.post("/api/v1/worker/jobs", json=payload)
    assert response.status_code == 201, response.text
    return response.json()


def test_get_pending_jobs():
    created = _create_job()
    response = client.get("/api/v1/jobs/requests/pending", params={"worker_id": "WORKER-JOB-TEST"})
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert any(item["id"] == created["id"] for item in data)
    assert "customer" in created


def test_get_job_details():
    created = _create_job(worker_user_id="WORKER-JOB-DETAIL")
    response = client.get(f"/api/v1/jobs/{created['id']}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == created["id"]
    assert data["customer"]["name"] == "Test Customer"
    assert data["pricing"]["total_min"] == 250
    assert data["pricing"]["total_max"] == 500


def test_accept_job():
    created = _create_job(worker_user_id="WORKER-JOB-ACCEPT")
    response = client.post(f"/api/v1/jobs/{created['id']}/accept")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["status"] == "ACCEPTED"
    assert data["message_key"] == "jobAcceptedSuccessToast"


def test_reject_job():
    created = _create_job(worker_user_id="WORKER-JOB-REJECT")
    response = client.post(f"/api/v1/jobs/{created['id']}/reject")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["status"] == "REJECTED"
    assert data["message_key"] == "jobRejectedSuccessToast"
