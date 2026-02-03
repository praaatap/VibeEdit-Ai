"""
AI API endpoints
"""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional, List
from enum import Enum

from app.core.security import get_current_user, UserContext
from app.services.langchain_service import LangChainService

router = APIRouter()

# Initialize LangChain service
langchain_service = LangChainService()


class EmotionType(str, Enum):
    ENERGETIC = "energetic"
    EMOTIONAL = "emotional"
    MOTIVATIONAL = "motivational"
    SERIOUS = "serious"
    FUNNY = "funny"
    CALM = "calm"


class AnalyzeRequest(BaseModel):
    transcript: str
    platform: str = "instagram_reels"
    tone: str = "viral"
    clip_count: int = 3
    creator_support_mode: bool = False


class ClipSuggestion(BaseModel):
    start_timestamp: str
    end_timestamp: str
    caption: str
    hook: str
    engagement_reason: str
    emotion: EmotionType
    confidence_score: float


class AnalyzeResponse(BaseModel):
    clips: List[ClipSuggestion]
    overall_emotion: EmotionType
    content_summary: str
    creator_feedback: str
    tips: List[str]


class EmotionDetectRequest(BaseModel):
    transcript: str
    include_timestamps: bool = False


class EmotionSegment(BaseModel):
    text: str
    emotion: EmotionType
    confidence: float
    start_time: Optional[str] = None
    end_time: Optional[str] = None


class EmotionDetectResponse(BaseModel):
    segments: List[EmotionSegment]
    dominant_emotion: EmotionType
    emotion_summary: str


class GenerateClipsRequest(BaseModel):
    video_id: str
    transcript: str
    platform: str = "instagram_reels"
    tone: str = "viral"
    clip_count: int = 3
    custom_prompt: Optional[str] = None
    creator_support_mode: bool = False


@router.post("/analyze", response_model=AnalyzeResponse)
async def analyze_content(
    request: AnalyzeRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Analyze video transcript and suggest clips
    """
    try:
        result = await langchain_service.analyze_transcript(
            transcript=request.transcript,
            platform=request.platform,
            tone=request.tone,
            clip_count=request.clip_count,
            creator_support_mode=request.creator_support_mode
        )
        
        return AnalyzeResponse(
            clips=result["clips"],
            overall_emotion=result["overall_emotion"],
            content_summary=result["content_summary"],
            creator_feedback=result["creator_feedback"],
            tips=result["tips"]
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Analysis encountered an issue 😕 Let's try again: {str(e)}"
        )


@router.post("/detect-emotions", response_model=EmotionDetectResponse)
async def detect_emotions(
    request: EmotionDetectRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Detect emotions in transcript segments
    """
    try:
        result = await langchain_service.detect_emotions(
            transcript=request.transcript,
            include_timestamps=request.include_timestamps
        )
        
        return EmotionDetectResponse(
            segments=result["segments"],
            dominant_emotion=result["dominant_emotion"],
            emotion_summary=result["emotion_summary"]
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Emotion detection had a hiccup 😕 Please try again: {str(e)}"
        )


@router.post("/generate-clips")
async def generate_clips(
    request: GenerateClipsRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Generate clip suggestions with AI
    """
    try:
        result = await langchain_service.generate_clip_suggestions(
            video_id=request.video_id,
            transcript=request.transcript,
            platform=request.platform,
            tone=request.tone,
            clip_count=request.clip_count,
            custom_prompt=request.custom_prompt,
            creator_support_mode=request.creator_support_mode
        )
        
        # Empathetic response based on results
        if result["clips"]:
            message = f"Found {len(result['clips'])} amazing moments! 🎉 These have strong engagement potential."
        else:
            message = "I couldn't find enough highlight moments 😕 Try with a longer video or adjust the settings."
        
        return {
            "video_id": request.video_id,
            "clips": result["clips"],
            "message": message,
            "creator_tips": result.get("tips", [])
        }
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Something went wrong 😕 Let's try again: {str(e)}"
        )


@router.get("/prompts/system")
async def get_system_prompt():
    """
    Get the VibeEdit AI system prompt (for transparency)
    """
    return {
        "system_prompt": langchain_service.get_system_prompt(),
        "message": "This is how I think about your videos 🧠"
    }
