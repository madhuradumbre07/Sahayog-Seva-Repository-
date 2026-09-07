from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlmodel import SQLModel
from app.core.config import settings

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
            elif settings.DATABASE_URL.startswith("sqlite"):
                await conn.execute(text("ALTER TABLE users ADD COLUMN is_registered BOOLEAN DEFAULT 1;"))
        except Exception:
            pass

async def get_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_factory() as session:
        yield session
