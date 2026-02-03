"""
Authentication API endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import Optional

from app.core.security import get_current_user, UserContext, verify_firebase_token

router = APIRouter()


class TokenVerifyRequest(BaseModel):
    """Token verification request"""
    token: str


class UserResponse(BaseModel):
    """User response model"""
    uid: str
    email: Optional[str] = None
    name: Optional[str] = None
    picture: Optional[str] = None
    message: str = "Welcome to VibeEdit AI! 💙"


@router.post("/verify", response_model=UserResponse)
async def verify_token(request: TokenVerifyRequest):
    """
    Verify Firebase ID token and return user info
    """
    user = await verify_firebase_token(request.token)
    return UserResponse(
        uid=user.uid,
        email=user.email,
        name=user.name,
        picture=user.picture,
        message=f"Welcome back, {user.name or 'Creator'}! 💙 Ready to create something amazing?"
    )


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: UserContext = Depends(get_current_user)):
    """
    Get current authenticated user info
    """
    return UserResponse(
        uid=current_user.uid,
        email=current_user.email,
        name=current_user.name,
        picture=current_user.picture,
        message=f"Hey {current_user.name or 'Creator'}! 🎬 Your creative journey continues..."
    )
