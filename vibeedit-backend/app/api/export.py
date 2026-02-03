"""
Export API - Video export with multiple formats and platform presets
"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional, List
from enum import Enum

from app.core.security import get_current_user, UserContext

router = APIRouter()


class ExportFormat(str, Enum):
    MP4 = "mp4"
    WEBM = "webm"
    MOV = "mov"
    GIF = "gif"
    PRORES = "prores"


class ExportQuality(str, Enum):
    LOW = "low"        # 480p
    MEDIUM = "medium"  # 720p
    HIGH = "high"      # 1080p
    ULTRA = "ultra"    # 4K


class Platform(str, Enum):
    INSTAGRAM_REELS = "instagram_reels"
    INSTAGRAM_STORY = "instagram_story"
    INSTAGRAM_FEED = "instagram_feed"
    YOUTUBE_SHORTS = "youtube_shorts"
    YOUTUBE = "youtube"
    YOUTUBE_4K = "youtube_4k"
    TIKTOK = "tiktok"
    TWITTER = "twitter"
    LINKEDIN = "linkedin"


class ExportRequest(BaseModel):
    video_id: str
    format: ExportFormat = ExportFormat.MP4
    quality: ExportQuality = ExportQuality.HIGH
    custom_width: Optional[int] = None
    custom_height: Optional[int] = None
    fps: Optional[int] = None


class PlatformExportRequest(BaseModel):
    video_id: str
    platform: Platform


class BatchExportRequest(BaseModel):
    video_id: str
    platforms: List[Platform]


class ThumbnailRequest(BaseModel):
    video_id: str
    timestamp: float = 0  # seconds
    width: int = 1280
    height: int = 720


@router.post("/video")
async def export_video(
    request: ExportRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Export video to specified format and quality
    
    Formats: MP4, WebM, MOV, GIF, ProRes
    Quality: low (480p), medium (720p), high (1080p), ultra (4K)
    """
    return {
        "video_id": request.video_id,
        "export": {
            "format": request.format.value,
            "quality": request.quality.value,
            "width": request.custom_width,
            "height": request.custom_height,
            "fps": request.fps
        },
        "status": "processing",
        "message": f"Exporting as {request.format.value.upper()} ({request.quality.value}) 📤"
    }


@router.post("/platform")
async def export_for_platform(
    request: PlatformExportRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Export video optimized for a specific platform
    
    Platforms: instagram_reels, youtube_shorts, tiktok, youtube, twitter, linkedin
    """
    platform_specs = {
        "instagram_reels": "1080x1920, 30fps, max 90s",
        "instagram_story": "1080x1920, 30fps, max 60s",
        "instagram_feed": "1080x1080, 30fps, max 60s",
        "youtube_shorts": "1080x1920, 60fps, max 60s",
        "youtube": "1920x1080, 60fps",
        "youtube_4k": "3840x2160, 60fps",
        "tiktok": "1080x1920, 60fps, max 3min",
        "twitter": "1280x720, 30fps, max 140s",
        "linkedin": "1920x1080, 30fps, max 10min"
    }
    
    return {
        "video_id": request.video_id,
        "platform": request.platform.value,
        "specs": platform_specs.get(request.platform.value),
        "status": "processing",
        "message": f"Optimizing for {request.platform.value.replace('_', ' ').title()} 📱"
    }


@router.post("/batch")
async def batch_export(
    request: BatchExportRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """Export video for multiple platforms at once"""
    return {
        "video_id": request.video_id,
        "platforms": [p.value for p in request.platforms],
        "total_exports": len(request.platforms),
        "status": "processing",
        "message": f"Exporting for {len(request.platforms)} platforms 🚀"
    }


@router.post("/thumbnail")
async def extract_thumbnail(
    request: ThumbnailRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """Extract a thumbnail/frame from video"""
    return {
        "video_id": request.video_id,
        "timestamp": request.timestamp,
        "dimensions": f"{request.width}x{request.height}",
        "status": "processing",
        "message": "Extracting thumbnail 🖼️"
    }


@router.post("/thumbnails")
async def extract_thumbnails(
    video_id: str,
    count: int = 5,
    width: int = 640,
    height: int = 360,
    current_user: UserContext = Depends(get_current_user)
):
    """Extract multiple thumbnails evenly spaced through video"""
    if count < 1 or count > 20:
        raise HTTPException(
            status_code=400,
            detail="Count must be between 1 and 20"
        )
    
    return {
        "video_id": video_id,
        "count": count,
        "dimensions": f"{width}x{height}",
        "status": "processing",
        "message": f"Extracting {count} thumbnails 🎞️"
    }


@router.post("/gif")
async def export_as_gif(
    video_id: str,
    width: int = 480,
    fps: int = 15,
    start_time: Optional[float] = None,
    duration: Optional[float] = None,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Export video as animated GIF
    
    Note: GIFs are optimized with 2-pass encoding for best quality
    """
    return {
        "video_id": video_id,
        "settings": {
            "width": width,
            "fps": fps,
            "start_time": start_time,
            "duration": duration
        },
        "status": "processing",
        "message": "Creating animated GIF 🎬"
    }


@router.get("/formats")
async def list_export_formats():
    """List all available export formats"""
    formats = [
        {
            "format": "mp4",
            "description": "Most compatible format, great for web",
            "codec": "H.264",
            "platforms": ["All platforms"]
        },
        {
            "format": "webm",
            "description": "Open format, smaller file size",
            "codec": "VP9",
            "platforms": ["Web browsers", "Discord"]
        },
        {
            "format": "mov",
            "description": "Apple format, high quality",
            "codec": "H.264/ProRes",
            "platforms": ["Apple devices", "Final Cut Pro"]
        },
        {
            "format": "gif",
            "description": "Animated images, limited colors",
            "codec": "GIF",
            "platforms": ["Web", "Social media"]
        },
        {
            "format": "prores",
            "description": "Professional editing format",
            "codec": "ProRes 422 HQ",
            "platforms": ["Professional editing software"]
        }
    ]
    return {"formats": formats}


@router.get("/platforms")
async def list_platform_presets():
    """List all platform export presets"""
    presets = [
        {
            "platform": "instagram_reels",
            "resolution": "1080x1920",
            "fps": 30,
            "max_duration": "90 seconds",
            "recommended_bitrate": "6 Mbps"
        },
        {
            "platform": "instagram_story",
            "resolution": "1080x1920",
            "fps": 30,
            "max_duration": "60 seconds",
            "recommended_bitrate": "5 Mbps"
        },
        {
            "platform": "instagram_feed",
            "resolution": "1080x1080",
            "fps": 30,
            "max_duration": "60 seconds",
            "recommended_bitrate": "5 Mbps"
        },
        {
            "platform": "youtube_shorts",
            "resolution": "1080x1920",
            "fps": 60,
            "max_duration": "60 seconds",
            "recommended_bitrate": "8 Mbps"
        },
        {
            "platform": "youtube",
            "resolution": "1920x1080",
            "fps": 60,
            "max_duration": "Unlimited",
            "recommended_bitrate": "12 Mbps"
        },
        {
            "platform": "youtube_4k",
            "resolution": "3840x2160",
            "fps": 60,
            "max_duration": "Unlimited",
            "recommended_bitrate": "35 Mbps"
        },
        {
            "platform": "tiktok",
            "resolution": "1080x1920",
            "fps": 60,
            "max_duration": "3 minutes",
            "recommended_bitrate": "6 Mbps"
        },
        {
            "platform": "twitter",
            "resolution": "1280x720",
            "fps": 30,
            "max_duration": "140 seconds",
            "recommended_bitrate": "5 Mbps"
        },
        {
            "platform": "linkedin",
            "resolution": "1920x1080",
            "fps": 30,
            "max_duration": "10 minutes",
            "recommended_bitrate": "8 Mbps"
        }
    ]
    return {"platforms": presets}


@router.get("/quality")
async def list_quality_presets():
    """List quality presets"""
    presets = [
        {
            "quality": "low",
            "resolution": "854x480",
            "bitrate": "1 Mbps",
            "audio_bitrate": "128 kbps",
            "use_case": "Quick previews, low bandwidth"
        },
        {
            "quality": "medium",
            "resolution": "1280x720",
            "bitrate": "3 Mbps",
            "audio_bitrate": "192 kbps",
            "use_case": "Good balance of quality and size"
        },
        {
            "quality": "high",
            "resolution": "1920x1080",
            "bitrate": "8 Mbps",
            "audio_bitrate": "256 kbps",
            "use_case": "HD quality for most platforms"
        },
        {
            "quality": "ultra",
            "resolution": "3840x2160",
            "bitrate": "20 Mbps",
            "audio_bitrate": "320 kbps",
            "use_case": "4K quality for premium content"
        }
    ]
    return {"quality_presets": presets}
