"""
Export Service - Professional video export with multiple formats and presets
"""
import subprocess
import os
from typing import Optional, List, Dict, Any
from pathlib import Path
from enum import Enum


class ExportFormat(str, Enum):
    MP4 = "mp4"
    WEBM = "webm"
    MOV = "mov"
    GIF = "gif"
    PRORES = "prores"
    AVI = "avi"


class ExportQuality(str, Enum):
    LOW = "low"        # 480p
    MEDIUM = "medium"  # 720p
    HIGH = "high"      # 1080p
    ULTRA = "ultra"    # 4K


class ExportService:
    """
    Video export service with multiple formats and quality presets
    """
    
    # Quality presets (width, height, bitrate)
    QUALITY_PRESETS = {
        "low": {"width": 854, "height": 480, "bitrate": "1M", "audio_bitrate": "128k"},
        "medium": {"width": 1280, "height": 720, "bitrate": "3M", "audio_bitrate": "192k"},
        "high": {"width": 1920, "height": 1080, "bitrate": "8M", "audio_bitrate": "256k"},
        "ultra": {"width": 3840, "height": 2160, "bitrate": "20M", "audio_bitrate": "320k"}
    }
    
    # Platform-specific presets
    PLATFORM_PRESETS = {
        "instagram_reels": {
            "width": 1080, "height": 1920, "fps": 30,
            "max_duration": 90, "bitrate": "6M"
        },
        "instagram_story": {
            "width": 1080, "height": 1920, "fps": 30,
            "max_duration": 60, "bitrate": "5M"
        },
        "instagram_feed": {
            "width": 1080, "height": 1080, "fps": 30,
            "max_duration": 60, "bitrate": "5M"
        },
        "youtube_shorts": {
            "width": 1080, "height": 1920, "fps": 60,
            "max_duration": 60, "bitrate": "8M"
        },
        "youtube": {
            "width": 1920, "height": 1080, "fps": 60,
            "max_duration": None, "bitrate": "12M"
        },
        "youtube_4k": {
            "width": 3840, "height": 2160, "fps": 60,
            "max_duration": None, "bitrate": "35M"
        },
        "tiktok": {
            "width": 1080, "height": 1920, "fps": 60,
            "max_duration": 180, "bitrate": "6M"
        },
        "twitter": {
            "width": 1280, "height": 720, "fps": 30,
            "max_duration": 140, "bitrate": "5M"
        },
        "linkedin": {
            "width": 1920, "height": 1080, "fps": 30,
            "max_duration": 600, "bitrate": "8M"
        }
    }
    
    def export_video(
        self,
        input_path: str,
        output_path: str,
        format: ExportFormat = ExportFormat.MP4,
        quality: ExportQuality = ExportQuality.HIGH,
        custom_width: Optional[int] = None,
        custom_height: Optional[int] = None,
        fps: Optional[int] = None
    ) -> str:
        """
        Export video to specified format and quality
        """
        preset = self.QUALITY_PRESETS[quality.value]
        width = custom_width or preset["width"]
        height = custom_height or preset["height"]
        
        if format == ExportFormat.GIF:
            return self._export_gif(input_path, output_path, width, fps or 15)
        elif format == ExportFormat.PRORES:
            return self._export_prores(input_path, output_path)
        else:
            return self._export_standard(
                input_path, output_path, format.value,
                width, height, preset["bitrate"], preset["audio_bitrate"], fps
            )
    
    def _export_standard(
        self,
        input_path: str,
        output_path: str,
        format: str,
        width: int,
        height: int,
        bitrate: str,
        audio_bitrate: str,
        fps: Optional[int] = None
    ) -> str:
        """Export to standard formats (MP4, WebM, MOV, AVI)"""
        
        # Codec settings per format
        codec_settings = {
            "mp4": {"vcodec": "libx264", "acodec": "aac"},
            "webm": {"vcodec": "libvpx-vp9", "acodec": "libopus"},
            "mov": {"vcodec": "libx264", "acodec": "aac"},
            "avi": {"vcodec": "libxvid", "acodec": "libmp3lame"}
        }
        
        settings = codec_settings.get(format, codec_settings["mp4"])
        
        # Build filter for scaling
        scale_filter = f"scale={width}:{height}:force_original_aspect_ratio=decrease,pad={width}:{height}:(ow-iw)/2:(oh-ih)/2"
        
        if fps:
            scale_filter += f",fps={fps}"
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", scale_filter,
            "-c:v", settings["vcodec"],
            "-b:v", bitrate,
            "-c:a", settings["acodec"],
            "-b:a", audio_bitrate,
            "-preset", "fast",
            "-movflags", "+faststart",  # Web optimization
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Video export failed: {e.stderr.decode()}")
    
    def _export_gif(
        self,
        input_path: str,
        output_path: str,
        width: int,
        fps: int = 15
    ) -> str:
        """Export as animated GIF"""
        # Two-pass for better quality
        import tempfile
        palette_path = tempfile.NamedTemporaryFile(suffix=".png", delete=False).name
        
        # Generate palette
        cmd1 = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", f"fps={fps},scale={width}:-1:flags=lanczos,palettegen=stats_mode=diff",
            palette_path
        ]
        
        # Generate GIF using palette
        cmd2 = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-i", palette_path,
            "-lavfi", f"fps={fps},scale={width}:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer",
            output_path
        ]
        
        try:
            subprocess.run(cmd1, check=True, capture_output=True)
            subprocess.run(cmd2, check=True, capture_output=True)
            os.unlink(palette_path)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"GIF export failed: {e.stderr.decode()}")
    
    def _export_prores(self, input_path: str, output_path: str) -> str:
        """Export as ProRes (professional quality)"""
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-c:v", "prores_ks",
            "-profile:v", "3",  # ProRes 422 HQ
            "-c:a", "pcm_s16le",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"ProRes export failed: {e.stderr.decode()}")
    
    def export_for_platform(
        self,
        input_path: str,
        output_path: str,
        platform: str
    ) -> str:
        """Export optimized for specific platform"""
        if platform not in self.PLATFORM_PRESETS:
            raise ValueError(f"Unknown platform: {platform}. Available: {list(self.PLATFORM_PRESETS.keys())}")
        
        preset = self.PLATFORM_PRESETS[platform]
        
        return self._export_standard(
            input_path, output_path, "mp4",
            preset["width"], preset["height"],
            preset["bitrate"], "256k",
            preset["fps"]
        )
    
    def batch_export(
        self,
        input_path: str,
        output_dir: str,
        platforms: List[str]
    ) -> Dict[str, str]:
        """Export video for multiple platforms at once"""
        results = {}
        
        for platform in platforms:
            if platform not in self.PLATFORM_PRESETS:
                continue
            
            output_filename = f"{Path(input_path).stem}_{platform}.mp4"
            output_path = os.path.join(output_dir, output_filename)
            
            try:
                self.export_for_platform(input_path, output_path, platform)
                results[platform] = output_path
            except Exception as e:
                results[platform] = f"Error: {str(e)}"
        
        return results
    
    def extract_thumbnail(
        self,
        input_path: str,
        output_path: str,
        timestamp: float = 0,
        width: int = 1280,
        height: int = 720
    ) -> str:
        """Extract a thumbnail/frame from video"""
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-ss", str(timestamp),
            "-vframes", "1",
            "-vf", f"scale={width}:{height}:force_original_aspect_ratio=decrease",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Thumbnail extraction failed: {e.stderr.decode()}")
    
    def extract_thumbnails(
        self,
        input_path: str,
        output_dir: str,
        count: int = 5,
        width: int = 640,
        height: int = 360
    ) -> List[str]:
        """Extract multiple thumbnails evenly spaced through video"""
        import json
        
        # Get video duration
        probe_cmd = [
            "ffprobe", "-v", "quiet",
            "-print_format", "json",
            "-show_format",
            input_path
        ]
        
        result = subprocess.run(probe_cmd, capture_output=True)
        info = json.loads(result.stdout)
        duration = float(info["format"]["duration"])
        
        # Calculate timestamps
        interval = duration / (count + 1)
        thumbnails = []
        
        for i in range(1, count + 1):
            timestamp = i * interval
            output_path = os.path.join(output_dir, f"thumb_{i:02d}.jpg")
            
            self.extract_thumbnail(input_path, output_path, timestamp, width, height)
            thumbnails.append(output_path)
        
        return thumbnails
    
    def get_video_info(self, input_path: str) -> Dict[str, Any]:
        """Get detailed video information"""
        import json
        
        cmd = [
            "ffprobe", "-v", "quiet",
            "-print_format", "json",
            "-show_format",
            "-show_streams",
            input_path
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, check=True)
            data = json.loads(result.stdout)
            
            video_stream = next(
                (s for s in data.get("streams", []) if s["codec_type"] == "video"),
                {}
            )
            audio_stream = next(
                (s for s in data.get("streams", []) if s["codec_type"] == "audio"),
                {}
            )
            
            return {
                "duration": float(data["format"].get("duration", 0)),
                "size_bytes": int(data["format"].get("size", 0)),
                "bitrate": int(data["format"].get("bit_rate", 0)),
                "format": data["format"].get("format_name"),
                "video": {
                    "codec": video_stream.get("codec_name"),
                    "width": video_stream.get("width"),
                    "height": video_stream.get("height"),
                    "fps": eval(video_stream.get("r_frame_rate", "0/1")),
                    "bitrate": int(video_stream.get("bit_rate", 0))
                },
                "audio": {
                    "codec": audio_stream.get("codec_name"),
                    "sample_rate": int(audio_stream.get("sample_rate", 0)),
                    "channels": audio_stream.get("channels"),
                    "bitrate": int(audio_stream.get("bit_rate", 0))
                }
            }
        except Exception as e:
            raise Exception(f"Failed to get video info: {str(e)}")


# Singleton instance
export_service = ExportService()
