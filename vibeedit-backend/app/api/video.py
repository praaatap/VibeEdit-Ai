"""
Video API endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, BackgroundTasks
from pydantic import BaseModel
from typing import Optional, List
from enum import Enum
import uuid
from datetime import datetime

from app.core.security import get_current_user, UserContext

router = APIRouter()


class VideoStatus(str, Enum):
    UPLOADING = "uploading"
    PROCESSING = "processing"
    TRANSCRIBING = "transcribing"
    ANALYZING = "analyzing"
    EDITING = "editing"
    COMPLETED = "completed"
    FAILED = "failed"


class Platform(str, Enum):
    INSTAGRAM_REELS = "instagram_reels"
    YOUTUBE_SHORTS = "youtube_shorts"
    TIKTOK = "tiktok"


class VideoTone(str, Enum):
    VIRAL = "viral"
    CINEMATIC = "cinematic"
    EMOTIONAL = "emotional"
    EDUCATIONAL = "educational"
    ENERGETIC = "energetic"


class VideoUploadResponse(BaseModel):
    id: str
    filename: str
    status: VideoStatus
    message: str
    created_at: datetime


class VideoProcessRequest(BaseModel):
    platform: Platform = Platform.INSTAGRAM_REELS
    tone: VideoTone = VideoTone.VIRAL
    clip_count: int = 3
    clip_duration_min: int = 15
    clip_duration_max: int = 60
    add_captions: bool = True
    creator_support_mode: bool = False
    custom_prompt: Optional[str] = None


class ClipInfo(BaseModel):
    id: str
    start_time: float
    end_time: float
    duration: float
    caption: Optional[str] = None
    engagement_score: float
    emotion: str
    download_url: Optional[str] = None


class VideoProcessResponse(BaseModel):
    video_id: str
    status: VideoStatus
    message: str
    clips: List[ClipInfo] = []
    progress: int = 0


# In-memory storage for demo (replace with database in production)
videos_db = {}


@router.post("/upload", response_model=VideoUploadResponse)
async def upload_video(
    file: UploadFile = File(...),
    title: Optional[str] = Form(None),
    current_user: UserContext = Depends(get_current_user)
):
    """
    Upload a video for processing
    """
    # Validate file type
    allowed_types = ["video/mp4", "video/quicktime", "video/x-msvideo", "video/webm"]
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail="Oops! 😕 Please upload a video file (MP4, MOV, AVI, or WebM)"
        )
    
    # Generate video ID
    video_id = str(uuid.uuid4())
    
    # Store video metadata
    videos_db[video_id] = {
        "id": video_id,
        "user_id": current_user.uid,
        "filename": file.filename,
        "title": title or file.filename,
        "status": VideoStatus.UPLOADING,
        "created_at": datetime.now(),
        "file_path": None,
        "clips": []
    }
    
    # TODO: Save file to cloud storage
    # For now, simulate upload success
    videos_db[video_id]["status"] = VideoStatus.PROCESSING
    
    return VideoUploadResponse(
        id=video_id,
        filename=file.filename,
        status=VideoStatus.PROCESSING,
        message="Your video is being crafted with care ✨ We'll find the best moments for you!",
        created_at=datetime.now()
    )


@router.get("/{video_id}")
async def get_video(
    video_id: str,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Get video metadata and status
    """
    if video_id not in videos_db:
        raise HTTPException(
            status_code=404,
            detail="Video not found 😕 It might have been moved or deleted."
        )
    
    video = videos_db[video_id]
    
    if video["user_id"] != current_user.uid:
        raise HTTPException(
            status_code=403,
            detail="This video belongs to another creator."
        )
    
    return video


@router.post("/{video_id}/process", response_model=VideoProcessResponse)
async def process_video(
    video_id: str,
    request: VideoProcessRequest,
    background_tasks: BackgroundTasks,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Process video with AI to generate clips
    """
    if video_id not in videos_db:
        raise HTTPException(
            status_code=404,
            detail="Video not found 😕"
        )
    
    video = videos_db[video_id]
    
    if video["user_id"] != current_user.uid:
        raise HTTPException(
            status_code=403,
            detail="This video belongs to another creator."
        )
    
    # Update status
    video["status"] = VideoStatus.ANALYZING
    video["process_config"] = request.dict()
    
    # Generate empathetic message based on settings
    if request.creator_support_mode:
        message = "Got it 💙 I'll handle your video with extra care, focusing on your authentic moments."
    elif request.tone == VideoTone.EMOTIONAL:
        message = "I'll preserve the emotional depth of your content while finding powerful moments ✨"
    elif request.tone == VideoTone.ENERGETIC:
        message = "Let's create something exciting! 🔥 Finding your most dynamic moments..."
    else:
        message = "Your video is being analyzed with AI magic ✨ This won't take long!"
    
    # TODO: Add background task for actual processing
    # background_tasks.add_task(process_video_task, video_id, request)
    
    return VideoProcessResponse(
        video_id=video_id,
        status=VideoStatus.ANALYZING,
        message=message,
        clips=[],
        progress=10
    )


@router.get("/{video_id}/status", response_model=VideoProcessResponse)
async def get_video_status(
    video_id: str,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Get video processing status
    """
    if video_id not in videos_db:
        raise HTTPException(
            status_code=404,
            detail="Video not found 😕"
        )
    
    video = videos_db[video_id]
    
    if video["user_id"] != current_user.uid:
        raise HTTPException(
            status_code=403,
            detail="This video belongs to another creator."
        )
    
    # Status messages
    status_messages = {
        VideoStatus.UPLOADING: "Receiving your video... 📤",
        VideoStatus.PROCESSING: "Getting everything ready... ⚙️",
        VideoStatus.TRANSCRIBING: "Listening to your content... 🎧",
        VideoStatus.ANALYZING: "Finding the best moments... 🔍",
        VideoStatus.EDITING: "Crafting your clips with care... ✂️",
        VideoStatus.COMPLETED: "All done! 🎉 Your clips are ready!",
        VideoStatus.FAILED: "Something went wrong 😕 Let's try again."
    }
    
    return VideoProcessResponse(
        video_id=video_id,
        status=video["status"],
        message=status_messages.get(video["status"], "Processing..."),
        clips=[ClipInfo(**clip) for clip in video.get("clips", [])],
        progress=100 if video["status"] == VideoStatus.COMPLETED else 50
    )


@router.get("/{video_id}/download/{clip_id}")
async def download_clip(
    video_id: str,
    clip_id: str,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Get download URL for a processed clip
    """
    if video_id not in videos_db:
        raise HTTPException(
            status_code=404,
            detail="Video not found 😕"
        )
    
    video = videos_db[video_id]
    
    if video["user_id"] != current_user.uid:
        raise HTTPException(
            status_code=403,
            detail="This video belongs to another creator."
        )
    
    # TODO: Generate signed download URL from cloud storage
    return {
        "clip_id": clip_id,
        "download_url": f"https://storage.example.com/clips/{clip_id}.mp4",
        "message": "Your clip is ready to download! 🎬"
    }
