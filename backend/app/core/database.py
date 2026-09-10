from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlmodel import SQLModel
from app.core.config import settings
import app.models.wallet  # noqa: F401
import app.models.user  # noqa: F401
import app.models.cooperative  # noqa: F401
import app.models.worker  # noqa: F401
import app.models.worker_profile  # noqa: F401
import app.models.booking  # noqa: F401
import app.models.job  # noqa: F401
import app.models.payment_rating  # noqa: F401
import app.models.address  # noqa: F401
import app.models.notification  # noqa: F401

# Engine configuration
connect_args = {}
if settings.DATABASE_URL.startswith("sqlite"):
    connect_args["check_same_thread"] = False

engine = create_async_engine(
    settings.DATABASE_URL,
    echo=False,
    future=True,
    connect_args=connect_args,
)

async_session_factory = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

from sqlalchemy import text

async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)
        try:
            if settings.DATABASE_URL.startswith("postgresql"):
                await conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS is_registered BOOLEAN DEFAULT TRUE;"))
                await conn.execute(text("ALTER TABLE worker_profiles ADD COLUMN IF NOT EXISTS email VARCHAR;"))
                await conn.execute(text("ALTER TABLE worker_profiles ADD COLUMN IF NOT EXISTS location VARCHAR;"))
                await conn.execute(text("ALTER TABLE worker_profiles ADD COLUMN IF NOT EXISTS rating_avg FLOAT;"))
                await conn.execute(text("ALTER TABLE worker_profiles ADD COLUMN IF NOT EXISTS review_count INTEGER;"))
                await conn.execute(text("ALTER TABLE worker_profiles ADD COLUMN IF NOT EXISTS availability_status VARCHAR DEFAULT 'OFFLINE';"))
                await conn.execute(text("ALTER TABLE workers ADD COLUMN IF NOT EXISTS user_id VARCHAR;"))
                await conn.execute(text("ALTER TABLE worker_jobs ADD COLUMN IF NOT EXISTS worker_user_id VARCHAR;"))
                await conn.execute(text("ALTER TABLE worker_jobs ADD COLUMN IF NOT EXISTS booking_id VARCHAR;"))
                await conn.execute(text("ALTER TABLE worker_jobs ADD COLUMN IF NOT EXISTS assigned_worker_id INTEGER;"))
            elif settings.DATABASE_URL.startswith("sqlite"):
                try:
                    await conn.execute(text("ALTER TABLE users ADD COLUMN is_registered BOOLEAN DEFAULT 1;"))
                except Exception:
                    pass
                try:
                    await conn.execute(text("ALTER TABLE worker_profiles ADD COLUMN email TEXT;"))
                except Exception:
                    pass
                try:
                    await conn.execute(text("ALTER TABLE worker_profiles ADD COLUMN location TEXT;"))
                except Exception:
                    pass
                try:
                    await conn.execute(text("ALTER TABLE worker_profiles ADD COLUMN rating_avg REAL;"))
                except Exception:
                    pass
                try:
                    await conn.execute(text("ALTER TABLE worker_profiles ADD COLUMN review_count INTEGER;"))
                except Exception:
                    pass
                try:
                    await conn.execute(text("ALTER TABLE worker_profiles ADD COLUMN availability_status TEXT;"))
                except Exception:
                    pass
                try:
                    await conn.execute(text("ALTER TABLE workers ADD COLUMN user_id TEXT;"))
                except Exception:
                    pass
                try:
                    await conn.execute(text("ALTER TABLE worker_jobs ADD COLUMN worker_user_id TEXT;"))
                except Exception:
                    pass
                try:
                    await conn.execute(text("ALTER TABLE worker_jobs ADD COLUMN booking_id TEXT;"))
                except Exception:
                    pass
                try:
                    await conn.execute(text("ALTER TABLE worker_jobs ADD COLUMN assigned_worker_id INTEGER;"))
                except Exception:
                    pass
        except Exception:
            pass

async def get_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_factory() as session:
        yield session
