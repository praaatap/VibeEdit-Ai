"""
Video Editor Service - FFmpeg/MoviePy operations
"""
import subprocess
import os
import tempfile
from typing import Optional, List, Tuple
from pathlib import Path
import json


class VideoEditorService:
    """
    Video editing service using FFmpeg and MoviePy
    """
    
    # Aspect ratios for different platforms
    ASPECT_RATIOS = {
        "instagram_reels": (9, 16),
        "youtube_shorts": (9, 16),
        "tiktok": (9, 16),
        "instagram_feed": (1, 1),
        "youtube": (16, 9)
    }
    
    def __init__(self, output_dir: str = None):
        """Initialize video editor service"""
        self.output_dir = output_dir or tempfile.mkdtemp(prefix="vibeedit_")
        Path(self.output_dir).mkdir(parents=True, exist_ok=True)
    
    def trim_video(
        self,
        input_path: str,
        output_path: str,
        start_time: float,
        end_time: float
    ) -> str:
        """
        Trim video to specified time range
        """
        duration = end_time - start_time
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-ss", str(start_time),
            "-t", str(duration),
            "-c:v", "libx264",
            "-c:a", "aac",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Video trimming failed: {e.stderr.decode()}")
    
    def resize_for_platform(
        self,
        input_path: str,
        output_path: str,
        platform: str = "instagram_reels"
    ) -> str:
        """
        Resize video for specific platform aspect ratio
        """
        aspect = self.ASPECT_RATIOS.get(platform, (9, 16))
        
        # Calculate dimensions (1080 width for vertical, 1920 for horizontal)
        if aspect[0] < aspect[1]:  # Vertical
            width = 1080
            height = int(1080 * aspect[1] / aspect[0])
        else:  # Horizontal or square
            width = 1920
            height = int(1920 * aspect[1] / aspect[0])
        
        # FFmpeg filter for center crop and scale
        filter_complex = f"scale={width}:{height}:force_original_aspect_ratio=increase,crop={width}:{height}"
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", filter_complex,
            "-c:v", "libx264",
            "-c:a", "aac",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Video resizing failed: {e.stderr.decode()}")
    
    def add_captions(
        self,
        input_path: str,
        output_path: str,
        captions: List[dict],
        style: str = "default"
    ) -> str:
        """
        Add captions/subtitles to video
        
        captions format:
        [
            {"start": 0.0, "end": 2.5, "text": "Hello world"},
            {"start": 2.5, "end": 5.0, "text": "This is VibeEdit AI"}
        ]
        """
        # Create SRT file
        srt_path = os.path.join(self.output_dir, "captions.srt")
        self._create_srt(captions, srt_path)
        
        # Caption styles
        styles = {
            "default": "FontSize=24,PrimaryColour=&HFFFFFF&,OutlineColour=&H000000&,Outline=2",
            "bold": "FontSize=28,PrimaryColour=&HFFFFFF&,OutlineColour=&H000000&,Outline=3,Bold=1",
            "viral": "FontSize=32,PrimaryColour=&H00FFFF&,OutlineColour=&H000000&,Outline=3,Bold=1",
            "cinematic": "FontSize=22,PrimaryColour=&HFFFFFF&,OutlineColour=&H000000&,Outline=1"
        }
        
        style_str = styles.get(style, styles["default"])
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", f"subtitles={srt_path}:force_style='{style_str}'",
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Caption addition failed: {e.stderr.decode()}")
    
    def _create_srt(self, captions: List[dict], output_path: str):
        """Create SRT subtitle file from captions"""
        with open(output_path, "w", encoding="utf-8") as f:
            for i, caption in enumerate(captions, 1):
                start = self._seconds_to_srt_time(caption["start"])
                end = self._seconds_to_srt_time(caption["end"])
                text = caption["text"]
                f.write(f"{i}\n{start} --> {end}\n{text}\n\n")
    
    def _seconds_to_srt_time(self, seconds: float) -> str:
        """Convert seconds to SRT time format (HH:MM:SS,mmm)"""
        hours = int(seconds // 3600)
        minutes = int((seconds % 3600) // 60)
        secs = int(seconds % 60)
        millis = int((seconds % 1) * 1000)
        return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"
    
    def merge_clips(
        self,
        input_paths: List[str],
        output_path: str
    ) -> str:
        """
        Merge multiple video clips into one
        """
        # Create concat file
        concat_path = os.path.join(self.output_dir, "concat.txt")
        with open(concat_path, "w") as f:
            for path in input_paths:
                f.write(f"file '{path}'\n")
        
        cmd = [
            "ffmpeg", "-y",
            "-f", "concat",
            "-safe", "0",
            "-i", concat_path,
            "-c:v", "libx264",
            "-c:a", "aac",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Video merge failed: {e.stderr.decode()}")
    
    def get_video_info(self, input_path: str) -> dict:
        """
        Get video metadata using ffprobe
        """
        cmd = [
            "ffprobe",
            "-v", "quiet",
            "-print_format", "json",
            "-show_format",
            "-show_streams",
            input_path
        ]
        
        try:
            result = subprocess.run(cmd, check=True, capture_output=True)
            return json.loads(result.stdout)
        except subprocess.CalledProcessError as e:
            raise Exception(f"Failed to get video info: {e.stderr.decode()}")
    
    def extract_audio(self, input_path: str, output_path: str) -> str:
        """
        Extract audio from video for transcription
        """
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vn",
            "-acodec", "pcm_s16le",
            "-ar", "16000",
            "-ac", "1",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Audio extraction failed: {e.stderr.decode()}")
    
    def add_fade_effects(
        self,
        input_path: str,
        output_path: str,
        fade_in: float = 0.5,
        fade_out: float = 0.5
    ) -> str:
        """
        Add fade in/out effects to video
        """
        # Get video duration first
        info = self.get_video_info(input_path)
        duration = float(info["format"]["duration"])
        
        fade_out_start = duration - fade_out
        
        filter_complex = f"fade=t=in:st=0:d={fade_in},fade=t=out:st={fade_out_start}:d={fade_out}"
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", filter_complex,
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Fade effects failed: {e.stderr.decode()}")


# Singleton instance
video_editor = VideoEditorService()
