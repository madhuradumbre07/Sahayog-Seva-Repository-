import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_get_pending_jobs():
    response = client.get("/api/v1/jobs/requests/pending")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    assert data[0]["id"] == "REQ-250531-0178"
    assert data[0]["priority"] == "HIGH"
    assert "customer" in data[0]

def test_get_job_details():
    response = client.get("/api/v1/jobs/REQ-250531-0178")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == "REQ-250531-0178"
    assert data["customer"]["name"] == "Sandeep Patil"
    assert len(data["scope_of_work"]) == 5
    assert len(data["required_tools"]) == 5
    assert data["pricing"]["total_min"] == 250
    assert data["pricing"]["total_max"] == 500

def test_accept_job():
    response = client.post("/api/v1/jobs/REQ-250531-0178/accept")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["status"] == "ACCEPTED"
    assert data["message_key"] == "jobAcceptedSuccessToast"

def test_reject_job():
    response = client.post("/api/v1/jobs/REQ-250531-0179/reject")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["status"] == "REJECTED"
    assert data["message_key"] == "jobRejectedSuccessToast"
