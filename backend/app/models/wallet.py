import uuid
from datetime import datetime
from typing import Optional, List
from sqlmodel import SQLModel, Field


# ------------------------------------------------------------------------------
# Database Tables (SQLModel)
# ------------------------------------------------------------------------------

class Wallet(SQLModel, table=True):
    __tablename__ = "wallets"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(index=True, unique=True, description="User identifier e.g. mobile or CUST-9842")
    balance: float = Field(default=0.0, description="Current available wallet balance")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class WalletTransaction(SQLModel, table=True):
    __tablename__ = "wallet_transactions"

    id: Optional[int] = Field(default=None, primary_key=True)
    transaction_id: str = Field(index=True, unique=True, description="Unique transaction ID e.g. TXN_WAL_1712345")
    user_id: str = Field(index=True)
    order_id: Optional[str] = Field(default=None, index=True)
    amount: float = Field(..., description="Positive amount for credit, negative/positive magnitude")
    transaction_type: str = Field(..., description="CREDIT or DEBIT")
    status: str = Field(default="SUCCESS", description="SUCCESS, FAILED, or PENDING")
    payment_method: str = Field(default="SANDBOX_GATEWAY", description="Payment instrument")
    gateway_payment_id: Optional[str] = Field(default=None)
    gateway_signature: Optional[str] = Field(default=None)
    description: str = Field(default="Wallet Transaction")
    balance_after: float = Field(default=0.0)
    created_at: datetime = Field(default_factory=datetime.utcnow)


class PaymentOrder(SQLModel, table=True):
    __tablename__ = "payment_orders"

    id: Optional[int] = Field(default=None, primary_key=True)
    order_id: str = Field(index=True, unique=True, description="Gateway order ID e.g. ord_sb_12345")
    user_id: str = Field(index=True)
    amount: float = Field(...)
    currency: str = Field(default="INR")
    status: str = Field(default="CREATED", description="CREATED, PAID, FAILED, CANCELLED")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


# ------------------------------------------------------------------------------
# Request & Response DTOs
# ------------------------------------------------------------------------------

class CreateOrderRequest(SQLModel):
    user_id: str = Field(...)
    amount: float = Field(..., gt=0)


class CreateOrderResponse(SQLModel):
    order_id: str
    amount: float
    currency: str = "INR"
    sandbox_key: str = "sb_key_test_sahayogseva"
    signature_hash: str
    message: str = "Payment order created successfully in sandbox mode."


class VerifyPaymentRequest(SQLModel):
    user_id: str = Field(...)
    order_id: str = Field(...)
    gateway_payment_id: str = Field(...)
    gateway_signature: str = Field(...)
    simulate_failure: bool = Field(default=False, description="Optionally simulate verification failure")


class VerifyPaymentResponse(SQLModel):
    success: bool
    new_balance: float
    transaction_id: Optional[str] = None
    message: str


class WalletBalanceResponse(SQLModel):
    user_id: str
    balance: float
    updated_at: str


class WalletTransactionRead(SQLModel):
    id: int
    transaction_id: str
    user_id: str
    order_id: Optional[str] = None
    amount: float
    transaction_type: str
    status: str
    payment_method: str
    gateway_payment_id: Optional[str] = None
    description: str
    balance_after: float
    created_at: str
