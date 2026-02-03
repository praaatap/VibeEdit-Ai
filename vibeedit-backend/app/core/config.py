"""
Core configuration settings
"""
from pydantic_settings import BaseSettings
from typing import List
import os


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # App
    APP_NAME: str = "VibeEdit AI"
    DEBUG: bool = True
    API_VERSION: str = "v1"
    
    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://user:password@localhost:5432/vibeedit"
    
    # Firebase
    FIREBASE_CREDENTIALS_PATH: str = "./firebase-credentials.json"
    
    # AI Providers
    OPENAI_API_KEY: str = ""
    GOOGLE_API_KEY: str = ""
    
    # Cloud Storage - AWS
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    AWS_S3_BUCKET: str = "vibeedit-videos"
    AWS_REGION: str = "us-east-1"
    
    # Cloud Storage - GCS
    GCS_BUCKET: str = "vibeedit-videos"
    GCS_CREDENTIALS_PATH: str = "./gcs-credentials.json"
    
    # Whisper
    WHISPER_MODEL: str = "base"
    
    # CORS
    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:8080"
    
    @property
    def cors_origins_list(self) -> List[str]:
        """Get CORS origins as a list"""
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",")]
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
