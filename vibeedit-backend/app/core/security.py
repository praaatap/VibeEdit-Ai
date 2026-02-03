"""
Security module - Firebase Auth verification
"""
from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional
import firebase_admin
from firebase_admin import credentials, auth
import os

from app.core.config import settings

# Initialize Firebase Admin SDK
firebase_app = None


def init_firebase():
    """Initialize Firebase Admin SDK"""
    global firebase_app
    if firebase_app is None:
        try:
            if os.path.exists(settings.FIREBASE_CREDENTIALS_PATH):
                cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
                firebase_app = firebase_admin.initialize_app(cred)
            else:
                # For development without credentials
                print("⚠️ Firebase credentials not found. Running in demo mode.")
        except Exception as e:
            print(f"⚠️ Firebase initialization error: {e}")


# Initialize on module load
init_firebase()

# Bearer token scheme
bearer_scheme = HTTPBearer(auto_error=False)


class UserContext:
    """User context extracted from Firebase token"""
    def __init__(self, uid: str, email: str = None, name: str = None, picture: str = None):
        self.uid = uid
        self.email = email
        self.name = name
        self.picture = picture
    
    def to_dict(self):
        return {
            "uid": self.uid,
            "email": self.email,
            "name": self.name,
            "picture": self.picture
        }


async def verify_firebase_token(token: str) -> UserContext:
    """Verify Firebase ID token and return user context"""
    try:
        decoded_token = auth.verify_id_token(token)
        return UserContext(
            uid=decoded_token.get("uid"),
            email=decoded_token.get("email"),
            name=decoded_token.get("name"),
            picture=decoded_token.get("picture")
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication token: {str(e)}"
        )


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme)
) -> UserContext:
    """Get current authenticated user from request"""
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required"
        )
    
    return await verify_firebase_token(credentials.credentials)


async def get_optional_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(bearer_scheme)
) -> Optional[UserContext]:
    """Get current user if authenticated, otherwise return None"""
    if credentials is None:
        return None
    
    try:
        return await verify_firebase_token(credentials.credentials)
    except HTTPException:
        return None
