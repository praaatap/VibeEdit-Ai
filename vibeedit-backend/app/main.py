"""
VibeEdit AI Backend
Main application entry point
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.config import settings
from app.api import auth, video, ai, effects, audio, export
from app.services.task_queue import task_queue


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events"""
    # Startup
    print("🚀 VibeEdit AI is starting up...")
    await task_queue.start()
    yield
    # Shutdown
    await task_queue.stop()
    print("👋 VibeEdit AI is shutting down...")


app = FastAPI(
    title=settings.APP_NAME,
    description="AI-powered video editing platform - Transform long videos into viral-ready clips",
    version=settings.API_VERSION,
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(video.router, prefix="/api/video", tags=["Video"])
app.include_router(ai.router, prefix="/api/ai", tags=["AI"])
app.include_router(effects.router, prefix="/api/effects", tags=["Effects"])
app.include_router(audio.router, prefix="/api/audio", tags=["Audio"])
app.include_router(export.router, prefix="/api/export", tags=["Export"])


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "message": "VibeEdit AI is ready 💙",
        "version": settings.API_VERSION
    }


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "app": settings.APP_NAME,
        "message": "Welcome to VibeEdit AI! 🎬✨",
        "docs": "/docs",
        "health": "/health"
    }
