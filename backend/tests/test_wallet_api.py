import pytest
from httpx import AsyncClient, ASGITransport
from sqlmodel import select
from app.main import app
from app.core.database import init_db, get_session
from app.models.wallet import Wallet, WalletTransaction, PaymentOrder
from app.api.v1.wallet import generate_sandbox_signature

@pytest.mark.anyio
async def test_wallet_full_sandbox_flow():
    await init_db()
    test_user = "CUST-9842-TEST"

    async for session in get_session():
        stmt_w = select(Wallet).where(Wallet.user_id == test_user)
        res_w = await session.execute(stmt_w)
        w = res_w.scalars().first()
        if w:
            await session.delete(w)
            stmt_t = select(WalletTransaction).where(WalletTransaction.user_id == test_user)
            res_t = await session.execute(stmt_t)
            for t in res_t.scalars().all():
                await session.delete(t)
            stmt_o = select(PaymentOrder).where(PaymentOrder.user_id == test_user)
            res_o = await session.execute(stmt_o)
            for o in res_o.scalars().all():
                await session.delete(o)
            await session.commit()
        break

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. Fetch initial balance (defaults to 1250.0)
        bal_res = await client.get(f"/api/v1/wallet/balance/{test_user}")
        assert bal_res.status_code == 200
        bal_data = bal_res.json()
        assert bal_data["user_id"] == test_user
        assert bal_data["balance"] == 1250.0

        # 2. Create payment order for ₹500
        order_res = await client.post(
            "/api/v1/wallet/create-order",
            json={"user_id": test_user, "amount": 500.0}
        )
        assert order_res.status_code == 201
        order_data = order_res.json()
        assert "order_id" in order_data
        order_id = order_data["order_id"]
        assert order_data["amount"] == 500.0
        assert order_data["currency"] == "INR"

        # 3. Verify payment with valid signature
        payment_id = "pay_sb_test_12345"
        valid_signature = generate_sandbox_signature(order_id, payment_id)

        verify_res = await client.post(
            "/api/v1/wallet/verify-payment",
            json={
                "user_id": test_user,
                "order_id": order_id,
                "gateway_payment_id": payment_id,
                "gateway_signature": valid_signature,
                "simulate_failure": False,
            }
        )
        assert verify_res.status_code == 200
        verify_data = verify_res.json()
        assert verify_data["success"] is True
        assert verify_data["new_balance"] == 1750.0  # 1250 + 500
        assert verify_data["transaction_id"].startswith("TXN_WAL_")

        # 4. Create second order and simulate verification failure
        fail_order_res = await client.post(
            "/api/v1/wallet/create-order",
            json={"user_id": test_user, "amount": 300.0}
        )
        fail_order_id = fail_order_res.json()["order_id"]

        fail_verify_res = await client.post(
            "/api/v1/wallet/verify-payment",
            json={
                "user_id": test_user,
                "order_id": fail_order_id,
                "gateway_payment_id": "pay_sb_fail_999",
                "gateway_signature": "invalid_signature",
                "simulate_failure": True,
            }
        )
        assert fail_verify_res.status_code == 200
        fail_verify_data = fail_verify_res.json()
        assert fail_verify_data["success"] is False
        assert fail_verify_data["new_balance"] == 1750.0  # Balance untouched!

        # 5. Fetch transactions history
        txn_res = await client.get(f"/api/v1/wallet/transactions/{test_user}")
        assert txn_res.status_code == 200
        txns = txn_res.json()
        assert len(txns) >= 2
        # Most recent transaction should be the failed one
        assert txns[0]["status"] == "FAILED"
        # Prior transaction should be the successful top-up
        assert txns[1]["status"] == "SUCCESS"
        assert txns[1]["amount"] == 500.0
        assert txns[1]["balance_after"] == 1750.0
