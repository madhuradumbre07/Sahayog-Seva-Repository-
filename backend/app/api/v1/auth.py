import hashlib
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
from datetime import datetime

from app.core.database import get_session
from app.models.user import User, UserCreate, UserRead, UserUpdate

try:
    import bcrypt
    def hash_password(password: str) -> str:
        pwd_bytes = password.encode('utf-8')
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
except Exception:
    def hash_password(password: str) -> str:
        return "sha256$" + hashlib.sha256(password.encode()).hexdigest()
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        return hash_password(plain_password) == hashed_password

router = APIRouter(prefix="/auth", tags=["Authentication & Registration"])

@router.post("/register", response_model=UserRead, status_code=status.HTTP_201_CREATED)
async def register_user(
    user_in: UserCreate,
    session: AsyncSession = Depends(get_session)
):
    """
    Register a new user with role-specific details and securely store the hashed password in the backend.
    """
    # Check if mobile already exists for this role
    stmt = select(User).where(User.mobile == user_in.mobile, User.role == user_in.role)
    result = await session.execute(stmt)
    existing_user = result.scalars().first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"An account with mobile number {user_in.mobile} is already registered as {user_in.role}."
        )

    # Hash the password
    hashed_pwd = hash_password(user_in.password)

    # Create new User instance
    user_dict = user_in.model_dump(exclude={"password"})
    user_dict["is_registered"] = True
    db_user = User(
        **user_dict,
        hashed_password=hashed_pwd,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )

    session.add(db_user)
    await session.commit()
    await session.refresh(db_user)

    return db_user

@router.get("/user/{mobile}")
async def get_user_by_mobile(
    mobile: str,
    session: AsyncSession = Depends(get_session)
):
    """
    Fetch all registered roles/profiles for a given mobile number.
    Used during OTP login to sync live user database profile.
    """
    stmt = select(User).where(User.mobile == mobile)
    result = await session.execute(stmt)
    users = result.scalars().all()
    if not users:
        return {"found": False, "users": []}
    return {
        "found": True,
        "users": [UserRead.model_validate(user).model_dump() for user in users]
    }

@router.get("/profile/{mobile}", response_model=UserRead)
async def get_user_profile(
    mobile: str,
    role: str = None,
    session: AsyncSession = Depends(get_session)
):
    """
    Fetch user registration profile details for settings/profile page.
    """
    if role:
        stmt = select(User).where(User.mobile == mobile, User.role == role)
        result = await session.execute(stmt)
        user = result.scalars().first()
        if user:
            return user

    # Fallback to any registered user matching mobile
    stmt = select(User).where(User.mobile == mobile)
    result = await session.execute(stmt)
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user

@router.put("/profile/{mobile}", response_model=UserRead)
async def update_user_profile(
    mobile: str,
    user_update: UserUpdate,
    role: str = "customer",
    session: AsyncSession = Depends(get_session)
):
    """
    Update user registration profile details from profile/settings page.
    """
    stmt = select(User).where(User.mobile == mobile, User.role == role)
    result = await session.execute(stmt)
    user = result.scalars().first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    update_data = user_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(user, field, value)
    
    user.updated_at = datetime.utcnow()
    session.add(user)
    await session.commit()
    await session.refresh(user)

    return user
