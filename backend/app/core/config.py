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
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:59613",
        "http://localhost:8000",
        "http://127.0.0.1:59613",
        "http://127.0.0.1:8000",
        "*"
    ]
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")

    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
