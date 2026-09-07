import uuid
from datetime import datetime
from fastapi import APIRouter, HTTPException, status
from app.models.payment_rating import PaymentProcessRequest, PaymentProcessResponse

router = APIRouter(prefix="/payments", tags=["Payments"])

@router.post("/process", response_model=PaymentProcessResponse)
async def process_payment(req: PaymentProcessRequest):
    if req.amount <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment amount must be greater than zero."
        )
    
    unique_suffix = uuid.uuid4().hex[:10].upper()
    txn_id = f"UPIS{unique_suffix}" if "UPI" in req.payment_method.upper() else f"TXN{unique_suffix}"
    invoice_no = f"INV-{datetime.now().strftime('%y%m%d')}-{uuid.uuid4().hex[:4].upper()}"
    
    return PaymentProcessResponse(
        status="PAYMENT_SUCCESS",
        booking_id=req.booking_id,
        txn_id=txn_id,
        amount=req.amount,
        payment_method=req.payment_method,
        timestamp=datetime.now().strftime("%Y-%m-%d %I:%M %p"),
        invoice_number=invoice_no,
        message="Payment processed successfully"
    )
