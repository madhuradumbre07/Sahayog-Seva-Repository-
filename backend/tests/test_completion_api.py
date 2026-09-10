from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_process_payment_endpoint():
    payload = {
        "booking_id": "SHS-842109",
        "customer_id": "CUST-9842",
        "payment_method": "UPI (Google Pay)",
        "amount": 420.0
    }
    response = client.post("/api/v1/payments/process", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "PAYMENT_SUCCESS"
    assert data["booking_id"] == "SHS-842109"
    assert data["amount"] == 420.0
    assert "UPIS" in data["txn_id"]
    assert "INV-" in data["invoice_number"]

def test_submit_rating_endpoint():
    payload = {
        "booking_id": "SHS-842109",
        "worker_id": 1,
        "rating": 5.0,
        "review_text": "Great work on tap repair!",
        "tags": ["Punctual", "Clean Work"]
    }
    response = client.post("/api/v1/ratings/submit", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "RATED"
    assert data["rating"] == 5.0
    assert data["total_reviews"] >= 1
    assert data["updated_average_rating"] >= 1.0

def test_invoice_pdf_endpoint():
    response = client.get("/api/v1/invoices/SHS-842109/pdf")
    assert response.status_code == 200
    data = response.json()
    assert data["booking_id"] == "SHS-842109"
    assert data["total_amount"] == 420.0
    assert data["invoice_number"] == "INV-250531-1123"
