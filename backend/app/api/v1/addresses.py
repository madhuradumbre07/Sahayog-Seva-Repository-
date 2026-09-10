from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from typing import List

from app.core.database import get_session
from app.models.address import (
    CustomerAddress,
    CustomerAddressCreate,
    CustomerAddressRead,
)

router = APIRouter(prefix="/addresses", tags=["Customer Saved Addresses"])

@router.get("", response_model=List[CustomerAddressRead])
async def get_saved_addresses(
    customer_id: str,
    session: AsyncSession = Depends(get_session)
):
    stmt = (
        select(CustomerAddress)
        .where(CustomerAddress.customer_id == customer_id)
        .order_by(CustomerAddress.is_default.desc(), CustomerAddress.created_at.desc())
    )
    result = await session.execute(stmt)
    addresses = result.scalars().all()

    # If user has no addresses yet, create default Home address
    if not addresses:
        default_addr = CustomerAddress(
            customer_id=customer_id,
            title="Home",
            address_line="102, Ganesh Apartments, Warje, Pune - 411058, Maharashtra",
            latitude=18.4800,
            longitude=73.8000,
            is_default=True,
        )
        session.add(default_addr)
        await session.commit()
        await session.refresh(default_addr)
        return [default_addr]

    return addresses

@router.post("", response_model=CustomerAddressRead, status_code=status.HTTP_201_CREATED)
async def create_saved_address(
    req: CustomerAddressCreate,
    session: AsyncSession = Depends(get_session)
):
    if req.is_default:
        # Reset other default addresses for this customer
        stmt = select(CustomerAddress).where(CustomerAddress.customer_id == req.customer_id)
        result = await session.execute(stmt)
        for addr in result.scalars().all():
            addr.is_default = False
            session.add(addr)

    address = CustomerAddress(
        customer_id=req.customer_id,
        title=req.title,
        address_line=req.address_line,
        latitude=req.latitude or 18.4800,
        longitude=req.longitude or 73.8000,
        is_default=bool(req.is_default),
    )
    session.add(address)
    await session.commit()
    await session.refresh(address)
    return address

@router.put("/{address_id}/default", response_model=CustomerAddressRead)
async def set_default_address(
    address_id: int,
    session: AsyncSession = Depends(get_session)
):
    stmt = select(CustomerAddress).where(CustomerAddress.id == address_id)
    result = await session.execute(stmt)
    address = result.scalars().first()
    if not address:
        raise HTTPException(status_code=404, detail="Address not found")

    # Unset existing defaults
    other_stmt = select(CustomerAddress).where(CustomerAddress.customer_id == address.customer_id)
    other_result = await session.execute(other_stmt)
    for other in other_result.scalars().all():
        other.is_default = (other.id == address_id)
        session.add(other)

    await session.commit()
    await session.refresh(address)
    return address

@router.delete("/{address_id}", status_code=status.HTTP_200_OK)
async def delete_saved_address(
    address_id: int,
    session: AsyncSession = Depends(get_session)
):
    stmt = select(CustomerAddress).where(CustomerAddress.id == address_id)
    result = await session.execute(stmt)
    address = result.scalars().first()
    if not address:
        raise HTTPException(status_code=404, detail="Address not found")

    await session.delete(address)
    await session.commit()
    return {"success": True, "message": "Address deleted successfully"}
