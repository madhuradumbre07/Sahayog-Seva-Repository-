from pydantic import BaseModel, Field
from typing import Optional, List

class PaymentProcessRequest(BaseModel):
    booking_id: str = Field(..., json_schema_extra={"example": "SHS-842109"})
    customer_id: str = Field(default="CUST-9842", json_schema_extra={"example": "CUST-9842"})
    payment_method: str = Field(..., json_schema_extra={"example": "UPI (Google Pay)"})
    amount: float = Field(..., json_schema_extra={"example": 420.0})

class PaymentProcessResponse(BaseModel):
    status: str = "PAYMENT_SUCCESS"
    booking_id: str
    txn_id: str
    amount: float
    payment_method: str
    timestamp: str
    invoice_number: str
    message: str = "Payment processed successfully"

class RatingSubmitRequest(BaseModel):
    booking_id: str = Field(..., json_schema_extra={"example": "SHS-842109"})
    worker_id: int = Field(..., json_schema_extra={"example": 1})
    rating: float = Field(..., ge=1.0, le=5.0, json_schema_extra={"example": 5.0})
    review_text: Optional[str] = Field(default="", max_length=500, json_schema_extra={"example": "Excellent tap repair service!"})
    tags: Optional[List[str]] = Field(default_factory=list, json_schema_extra={"example": ["Punctual", "Clean Work"]})

class RatingSubmitResponse(BaseModel):
    status: str = "RATED"
    booking_id: str
    worker_id: int
    rating: float
    review_text: Optional[str] = ""
    updated_average_rating: float = 4.8
    total_reviews: int = 157
    message: str = "Rating and review submitted successfully"

class InvoiceResponse(BaseModel):
    invoice_number: str
    booking_id: str
    customer_name: str
    worker_name: str
    service_category: str
    service_subcategory: str
    base_price: float
    materials_cost: float
    platform_fee: float
    discount_amount: float
    total_amount: float
    payment_method: str
    payment_status: str
    txn_id: str
    issued_at: str
    pdf_download_url: str
