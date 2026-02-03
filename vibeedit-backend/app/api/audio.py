"""
Audio API - Audio processing, mixing, and effects
"""
from fastapi import APIRouter, HTTPException, Depends, UploadFile, File, Form
from pydantic import BaseModel
from typing import Optional, List
from enum import Enum

from app.core.security import get_current_user, UserContext

router = APIRouter()


class BackgroundMusicRequest(BaseModel):
    video_id: str
    music_id: str
    music_volume: float = 0.3  # 0.0 to 1.0
    original_volume: float = 1.0  # 0.0 to 1.0
    fade_in: float = 0  # seconds
    fade_out: float = 0  # seconds


class VolumeRequest(BaseModel):
    video_id: str
    volume: float = 1.0  # 0.0 to 3.0


class NoiseReductionRequest(BaseModel):
    video_id: str
    reduction_amount: float = 0.21  # 0 to 1
    noise_floor: float = -30  # dB


class AudioFadeRequest(BaseModel):
    video_id: str
    fade_in: float = 0  # seconds
    fade_out: float = 0  # seconds


class AudioMixRequest(BaseModel):
    video_id: str
    tracks: List[dict]  # [{"path": "...", "volume": 0.5, "start": 0}]


@router.post("/extract")
async def extract_audio(
    video_id: str,
    format: str = "mp3",
    current_user: UserContext = Depends(get_current_user)
):
    """
    Extract audio track from video
    
    Formats: mp3, aac, wav, flac
    """
    valid_formats = ["mp3", "aac", "wav", "flac"]
    if format not in valid_formats:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid format. Choose from: {valid_formats}"
        )
    
    return {
        "video_id": video_id,
        "format": format,
        "status": "processing",
        "message": f"Extracting audio as {format.upper()} 🎵"
    }


@router.post("/background-music")
async def add_background_music(
    request: BackgroundMusicRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Add background music to video
    
    - **music_volume**: Volume of the background music (0.0 to 1.0)
    - **original_volume**: Volume of original audio (0.0 to 1.0)
    """
    return {
        "video_id": request.video_id,
        "music_id": request.music_id,
        "settings": {
            "music_volume": request.music_volume,
            "original_volume": request.original_volume,
            "fade_in": request.fade_in,
            "fade_out": request.fade_out
        },
        "status": "processing",
        "message": "Adding background music 🎶"
    }


@router.post("/replace")
async def replace_audio(
    video_id: str,
    audio_id: str,
    current_user: UserContext = Depends(get_current_user)
):
    """Replace video audio track completely"""
    return {
        "video_id": video_id,
        "audio_id": audio_id,
        "status": "processing",
        "message": "Replacing audio track 🔊"
    }


@router.post("/remove")
async def remove_audio(
    video_id: str,
    current_user: UserContext = Depends(get_current_user)
):
    """Remove audio track from video (mute)"""
    return {
        "video_id": video_id,
        "status": "processing",
        "message": "Removing audio track 🔇"
    }


@router.post("/volume")
async def adjust_volume(
    request: VolumeRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Adjust audio volume
    
    - **volume**: 0.0 (mute) to 3.0 (300%)
    """
    if not 0 <= request.volume <= 3.0:
        raise HTTPException(
            status_code=400,
            detail="Volume must be between 0.0 and 3.0"
        )
    
    return {
        "video_id": request.video_id,
        "volume": request.volume,
        "status": "processing",
        "message": f"Adjusting volume to {int(request.volume * 100)}% 🔊"
    }


@router.post("/normalize")
async def normalize_audio(
    video_id: str,
    target_level: float = -14.0,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Normalize audio levels (loudness normalization)
    
    - **target_level**: Target loudness in LUFS (-23 to -5)
    """
    return {
        "video_id": video_id,
        "target_level": target_level,
        "status": "processing",
        "message": "Normalizing audio levels 📊"
    }


@router.post("/noise-reduction")
async def reduce_noise(
    request: NoiseReductionRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Reduce background noise in audio
    
    - **reduction_amount**: 0 (none) to 1 (maximum)
    - **noise_floor**: dB threshold for noise detection
    """
    return {
        "video_id": request.video_id,
        "settings": {
            "reduction_amount": request.reduction_amount,
            "noise_floor": request.noise_floor
        },
        "status": "processing",
        "message": "Reducing background noise 🔕"
    }


@router.post("/fade")
async def add_audio_fade(
    request: AudioFadeRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """Add fade in/out effects to audio"""
    return {
        "video_id": request.video_id,
        "fade_in": request.fade_in,
        "fade_out": request.fade_out,
        "status": "processing",
        "message": "Adding audio fade effects 🎚️"
    }


@router.post("/mix")
async def mix_audio_tracks(
    request: AudioMixRequest,
    current_user: UserContext = Depends(get_current_user)
):
    """
    Mix multiple audio tracks with individual volume controls
    
    tracks format: [{"id": "audio_file_id", "volume": 0.5, "start": 0}]
    """
    return {
        "video_id": request.video_id,
        "tracks": request.tracks,
        "status": "processing",
        "message": f"Mixing {len(request.tracks)} audio tracks 🎛️"
    }


@router.post("/upload-music")
async def upload_music(
    file: UploadFile = File(...),
    title: Optional[str] = Form(None),
    current_user: UserContext = Depends(get_current_user)
):
    """Upload a music file for use in videos"""
    allowed_types = [
        "audio/mpeg", "audio/mp3", "audio/wav", 
        "audio/aac", "audio/ogg", "audio/flac"
    ]
    
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail="Please upload an audio file (MP3, WAV, AAC, OGG, FLAC)"
        )
    
    return {
        "filename": file.filename,
        "title": title or file.filename,
        "status": "uploaded",
        "message": "Music file uploaded successfully 🎵"
    }
