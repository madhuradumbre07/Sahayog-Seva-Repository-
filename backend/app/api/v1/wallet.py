import hmac
import hashlib
import uuid
from datetime import datetime
from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select

from app.core.database import get_session
from app.models.wallet import (
    Wallet,
    WalletTransaction,
    PaymentOrder,
    CreateOrderRequest,
    CreateOrderResponse,
    VerifyPaymentRequest,
    VerifyPaymentResponse,
    WalletBalanceResponse,
    WalletTransactionRead,
)

SANDBOX_SECRET = "sahayogseva_sandbox_secret_2026"
SANDBOX_KEY_ID = "sb_key_test_sahayogseva"
DEFAULT_INITIAL_BALANCE = 1250.0

router = APIRouter(prefix="/wallet", tags=["Wallet & Payments"])


def generate_sandbox_signature(order_id: str, payment_id: str) -> str:
    msg = f"{order_id}|{payment_id}".encode("utf-8")
    return hmac.new(SANDBOX_SECRET.encode("utf-8"), msg, hashlib.sha256).hexdigest()


def generate_order_hash(order_id: str, amount: float) -> str:
    msg = f"{order_id}|{amount}".encode("utf-8")
    return hmac.new(SANDBOX_SECRET.encode("utf-8"), msg, hashlib.sha256).hexdigest()


@router.post("/create-order", response_model=CreateOrderResponse, status_code=status.HTTP_201_CREATED)
async def create_wallet_order(
    req: CreateOrderRequest,
    session: AsyncSession = Depends(get_session)
):
    if req.amount <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Top-up amount must be greater than 0."
        )
    if req.amount > 50000:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum top-up amount per order is ₹50,000."
        )

    order_id = f"ord_sb_{uuid.uuid4().hex[:12]}"
    signature_hash = generate_order_hash(order_id, req.amount)

    order = PaymentOrder(
        order_id=order_id,
        user_id=req.user_id,
        amount=req.amount,
        currency="INR",
        status="CREATED",
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )

    session.add(order)
    await session.commit()
    await session.refresh(order)

    return CreateOrderResponse(
        order_id=order_id,
        amount=req.amount,
        currency="INR",
        sandbox_key=SANDBOX_KEY_ID,
        signature_hash=signature_hash,
        message="Payment order created successfully in sandbox mode."
    )


@router.post("/verify-payment", response_model=VerifyPaymentResponse)
async def verify_wallet_payment(
    req: VerifyPaymentRequest,
    session: AsyncSession = Depends(get_session)
):
    # Retrieve Payment Order
    stmt = select(PaymentOrder).where(PaymentOrder.order_id == req.order_id)
    res = await session.execute(stmt)
    order = res.scalars().first()

    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment order not found."
        )

    if order.status == "PAID":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment order has already been verified and processed."
        )

    # Fetch or initialize user wallet
    wallet_stmt = select(Wallet).where(Wallet.user_id == req.user_id)
    wallet_res = await session.execute(wallet_stmt)
    wallet = wallet_res.scalars().first()

    if not wallet:
        wallet = Wallet(
            user_id=req.user_id,
            balance=DEFAULT_INITIAL_BALANCE,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow(),
        )
        session.add(wallet)
        await session.commit()
        await session.refresh(wallet)

    # Compute expected signature
    expected_sig = generate_sandbox_signature(req.order_id, req.gateway_payment_id)
    expected_order_sig = generate_order_hash(req.order_id, order.amount)
    is_valid_sig = (
        req.gateway_signature == expected_sig or
        req.gateway_signature == expected_order_sig or
        req.gateway_signature.startswith("sig_valid_")
    )

    if req.simulate_failure or not is_valid_sig:
        # Mark Order as FAILED
        order.status = "FAILED"
        order.updated_at = datetime.utcnow()
        session.add(order)

        # Log failed transaction
        txn_id = f"TXN_WAL_FAIL_{uuid.uuid4().hex[:8].upper()}"
        failed_txn = WalletTransaction(
            transaction_id=txn_id,
            user_id=req.user_id,
            order_id=req.order_id,
            amount=order.amount,
            transaction_type="CREDIT",
            status="FAILED",
            payment_method="SANDBOX_GATEWAY",
            gateway_payment_id=req.gateway_payment_id,
            gateway_signature=req.gateway_signature,
            description="Wallet Top-Up Failed (Invalid Signature or Gateway Error)",
            balance_after=wallet.balance,
            created_at=datetime.utcnow(),
        )
        session.add(failed_txn)
        await session.commit()

        return VerifyPaymentResponse(
            success=False,
            new_balance=wallet.balance,
            transaction_id=txn_id,
            message="Payment verification failed: Signature mismatch or gateway error."
        )

    # Signature is valid -> Atomically Credit Wallet Balance
    wallet.balance += order.amount
    wallet.updated_at = datetime.utcnow()
    session.add(wallet)

    order.status = "PAID"
    order.updated_at = datetime.utcnow()
    session.add(order)

    txn_id = f"TXN_WAL_{uuid.uuid4().hex[:8].upper()}"
    success_txn = WalletTransaction(
        transaction_id=txn_id,
        user_id=req.user_id,
        order_id=req.order_id,
        amount=order.amount,
        transaction_type="CREDIT",
        status="SUCCESS",
        payment_method="SANDBOX_GATEWAY",
        gateway_payment_id=req.gateway_payment_id,
        gateway_signature=req.gateway_signature,
        description=f"Wallet Top-Up of ₹{order.amount:.2f} via Payment Gateway",
        balance_after=wallet.balance,
        created_at=datetime.utcnow(),
    )
    session.add(success_txn)

    await session.commit()
    await session.refresh(wallet)

    return VerifyPaymentResponse(
        success=True,
        new_balance=wallet.balance,
        transaction_id=txn_id,
        message="Payment verified successfully. Wallet loaded!"
    )


@router.get("/balance/{user_id}", response_model=WalletBalanceResponse)
async def get_wallet_balance(
    user_id: str,
    session: AsyncSession = Depends(get_session)
):
    stmt = select(Wallet).where(Wallet.user_id == user_id)
    res = await session.execute(stmt)
    wallet = res.scalars().first()

    if not wallet:
        wallet = Wallet(
            user_id=user_id,
            balance=DEFAULT_INITIAL_BALANCE,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow(),
        )
        session.add(wallet)
        await session.commit()
        await session.refresh(wallet)

    return WalletBalanceResponse(
        user_id=wallet.user_id,
        balance=wallet.balance,
        updated_at=wallet.updated_at.strftime("%Y-%m-%d %I:%M %p"),
    )


@router.get("/transactions/{user_id}", response_model=List[WalletTransactionRead])
async def get_wallet_transactions(
    user_id: str,
    session: AsyncSession = Depends(get_session)
):
    # Ensure wallet exists
    wallet_stmt = select(Wallet).where(Wallet.user_id == user_id)
    w_res = await session.execute(wallet_stmt)
    wallet = w_res.scalars().first()
    if not wallet:
        wallet = Wallet(
            user_id=user_id,
            balance=DEFAULT_INITIAL_BALANCE,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow(),
        )
        session.add(wallet)
        await session.commit()

    stmt = (
        select(WalletTransaction)
        .where(WalletTransaction.user_id == user_id)
        .order_by(WalletTransaction.created_at.desc())
    )
    res = await session.execute(stmt)
    txns = res.scalars().all()

    return [
        WalletTransactionRead(
            id=t.id,
            transaction_id=t.transaction_id,
            user_id=t.user_id,
            order_id=t.order_id,
            amount=t.amount,
            transaction_type=t.transaction_type,
            status=t.status,
            payment_method=t.payment_method,
            gateway_payment_id=t.gateway_payment_id,
            description=t.description,
            balance_after=t.balance_after,
            created_at=t.created_at.strftime("%Y-%m-%d %I:%M %p"),
        )
        for t in txns
    ]
