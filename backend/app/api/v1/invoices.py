from datetime import datetime
from fastapi import APIRouter
from app.models.payment_rating import InvoiceResponse

router = APIRouter(prefix="/invoices", tags=["Invoices"])

@router.get("/{booking_id}/pdf", response_model=InvoiceResponse)
async def get_invoice_pdf(booking_id: str):
    return InvoiceResponse(
        invoice_number="INV-250531-1123",
        booking_id=booking_id,
        customer_name="Customer User",
        worker_name="Rahul Sharma",
        service_category="Plumbing",
        service_subcategory="Tap & Faucet Repair",
        base_price=350.0,
        materials_cost=50.0,
        platform_fee=20.0,
        discount_amount=0.0,
        total_amount=420.0,
        payment_method="UPI (Google Pay)",
        payment_status="PAID",
        txn_id="UPIS1987451236",
        issued_at=datetime.now().strftime("%Y-%m-%d %I:%M %p"),
        pdf_download_url=f"/api/v1/invoices/{booking_id}/download.pdf"
    )
