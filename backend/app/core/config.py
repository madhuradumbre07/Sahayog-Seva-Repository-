import os
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    PROJECT_NAME: str = "SahayogSeva API"
    API_V1_STR: str = "/api/v1"
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "sqlite+aiosqlite:///./sahayogseva.db" if not os.getenv("POSTGRES_DB") else "postgresql+asyncpg://postgres:postgrespassword@localhost:5432/sahayogseva_db"
    )
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    BACKEND_CORS_ORIGINS: List[str] = ["*"]
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")

    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
