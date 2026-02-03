"""
Effects Service - Advanced video effects using FFmpeg
Industry-grade filters, color grading, and visual effects
"""
import subprocess
import os
from typing import Optional, List, Dict, Any
from pathlib import Path


class EffectsService:
    """
    Advanced video effects service using FFmpeg filters
    """
    
    # Preset LUT files for color grading
    LUTS = {
        "cinematic": "cinematic_lut.cube",
        "vintage": "vintage_lut.cube",
        "warm": "warm_lut.cube",
        "cool": "cool_lut.cube",
        "dramatic": "dramatic_lut.cube"
    }
    
    # Pre-defined filter presets
    FILTER_PRESETS = {
        "vibrant": {"saturation": 1.3, "contrast": 1.1, "brightness": 0.05},
        "muted": {"saturation": 0.7, "contrast": 0.9, "brightness": 0},
        "warm": {"saturation": 1.1, "contrast": 1.0, "brightness": 0.02},
        "cool": {"saturation": 0.9, "contrast": 1.05, "brightness": 0},
        "dramatic": {"saturation": 1.2, "contrast": 1.3, "brightness": -0.1},
        "soft": {"saturation": 0.85, "contrast": 0.95, "brightness": 0.05}
    }
    
    def adjust_speed(
        self,
        input_path: str,
        output_path: str,
        speed: float = 1.0
    ) -> str:
        """
        Adjust video playback speed
        
        Args:
            speed: 0.25 (4x slow-mo) to 4.0 (4x fast)
        """
        if speed <= 0 or speed > 4:
            raise ValueError("Speed must be between 0.25 and 4.0")
        
        # Video speed is inverse of setpts multiplier
        video_speed = 1 / speed
        # Audio tempo must be between 0.5 and 2.0, so we may need multiple passes
        audio_filters = self._get_audio_tempo_filter(speed)
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-filter_complex",
            f"[0:v]setpts={video_speed}*PTS[v];[0:a]{audio_filters}[a]",
            "-map", "[v]",
            "-map", "[a]",
            "-c:v", "libx264",
            "-c:a", "aac",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Speed adjustment failed: {e.stderr.decode()}")
    
    def _get_audio_tempo_filter(self, speed: float) -> str:
        """Generate audio tempo filter chain for given speed"""
        if 0.5 <= speed <= 2.0:
            return f"atempo={speed}"
        elif speed < 0.5:
            # Chain multiple atempo filters for very slow speeds
            return f"atempo=0.5,atempo={speed/0.5}"
        else:
            # Chain multiple atempo filters for very fast speeds
            return f"atempo=2.0,atempo={speed/2.0}"
    
    def apply_filters(
        self,
        input_path: str,
        output_path: str,
        brightness: float = 0,
        contrast: float = 1.0,
        saturation: float = 1.0,
        blur: float = 0,
        sharpen: float = 0,
        gamma: float = 1.0
    ) -> str:
        """
        Apply color and visual filters to video
        
        Args:
            brightness: -1.0 to 1.0 (0 = no change)
            contrast: 0.0 to 2.0 (1.0 = no change)
            saturation: 0.0 to 3.0 (1.0 = no change)
            blur: 0 to 10 (0 = no blur)
            sharpen: 0 to 2 (0 = no sharpen)
            gamma: 0.1 to 10.0 (1.0 = no change)
        """
        filters = []
        
        # Color adjustments
        if brightness != 0 or contrast != 1.0 or saturation != 1.0 or gamma != 1.0:
            filters.append(
                f"eq=brightness={brightness}:contrast={contrast}:"
                f"saturation={saturation}:gamma={gamma}"
            )
        
        # Blur effect
        if blur > 0:
            filters.append(f"boxblur={blur}:{blur}")
        
        # Sharpen effect
        if sharpen > 0:
            amount = min(sharpen, 2.0)
            filters.append(f"unsharp=5:5:{amount}:5:5:{amount/2}")
        
        if not filters:
            # No filters to apply, just copy
            filters.append("null")
        
        filter_chain = ",".join(filters)
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", filter_chain,
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Filter application failed: {e.stderr.decode()}")
    
    def apply_preset(
        self,
        input_path: str,
        output_path: str,
        preset: str
    ) -> str:
        """Apply a predefined filter preset"""
        if preset not in self.FILTER_PRESETS:
            raise ValueError(f"Unknown preset: {preset}. Available: {list(self.FILTER_PRESETS.keys())}")
        
        settings = self.FILTER_PRESETS[preset]
        return self.apply_filters(input_path, output_path, **settings)
    
    def to_grayscale(self, input_path: str, output_path: str) -> str:
        """Convert video to grayscale"""
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", "format=gray",
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Grayscale conversion failed: {e.stderr.decode()}")
    
    def to_sepia(self, input_path: str, output_path: str) -> str:
        """Apply sepia tone effect"""
        sepia_filter = (
            "colorchannelmixer="
            "rr=0.393:rg=0.769:rb=0.189:"
            "gr=0.349:gg=0.686:gb=0.168:"
            "br=0.272:bg=0.534:bb=0.131"
        )
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", sepia_filter,
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Sepia effect failed: {e.stderr.decode()}")
    
    def add_vignette(
        self,
        input_path: str,
        output_path: str,
        intensity: float = 0.5
    ) -> str:
        """Add vignette effect (darkened edges)"""
        angle = f"PI/{2 + (1 - intensity) * 4}"
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", f"vignette=angle={angle}",
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Vignette effect failed: {e.stderr.decode()}")
    
    def crop_video(
        self,
        input_path: str,
        output_path: str,
        width: int,
        height: int,
        x: int = 0,
        y: int = 0
    ) -> str:
        """Crop video to specified dimensions"""
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", f"crop={width}:{height}:{x}:{y}",
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Video cropping failed: {e.stderr.decode()}")
    
    def rotate_video(
        self,
        input_path: str,
        output_path: str,
        degrees: int = 90
    ) -> str:
        """
        Rotate video by specified degrees
        
        Args:
            degrees: 90, 180, 270, or any angle
        """
        if degrees == 90:
            transpose = "transpose=1"
        elif degrees == 180:
            transpose = "transpose=1,transpose=1"
        elif degrees == 270:
            transpose = "transpose=2"
        else:
            # Arbitrary rotation
            radians = degrees * 3.14159 / 180
            transpose = f"rotate={radians}"
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", transpose,
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Video rotation failed: {e.stderr.decode()}")
    
    def flip_video(
        self,
        input_path: str,
        output_path: str,
        horizontal: bool = True
    ) -> str:
        """Flip video horizontally or vertically"""
        flip_filter = "hflip" if horizontal else "vflip"
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", flip_filter,
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Video flip failed: {e.stderr.decode()}")
    
    def picture_in_picture(
        self,
        main_video: str,
        overlay_video: str,
        output_path: str,
        position: str = "bottom-right",
        scale: float = 0.25,
        margin: int = 20
    ) -> str:
        """
        Add picture-in-picture overlay
        
        Args:
            position: top-left, top-right, bottom-left, bottom-right, center
            scale: Size of overlay relative to main video (0.1 to 0.5)
            margin: Pixels from edge
        """
        # Position calculations
        positions = {
            "top-left": f"{margin}:{margin}",
            "top-right": f"main_w-overlay_w-{margin}:{margin}",
            "bottom-left": f"{margin}:main_h-overlay_h-{margin}",
            "bottom-right": f"main_w-overlay_w-{margin}:main_h-overlay_h-{margin}",
            "center": "(main_w-overlay_w)/2:(main_h-overlay_h)/2"
        }
        
        pos = positions.get(position, positions["bottom-right"])
        
        filter_complex = (
            f"[1:v]scale=iw*{scale}:ih*{scale}[pip];"
            f"[0:v][pip]overlay={pos}"
        )
        
        cmd = [
            "ffmpeg", "-y",
            "-i", main_video,
            "-i", overlay_video,
            "-filter_complex", filter_complex,
            "-c:v", "libx264",
            "-c:a", "aac",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Picture-in-picture failed: {e.stderr.decode()}")
    
    def chroma_key(
        self,
        input_path: str,
        background_path: str,
        output_path: str,
        color: str = "green",
        similarity: float = 0.3,
        blend: float = 0.1
    ) -> str:
        """
        Green screen / chroma key effect
        
        Args:
            color: green, blue, or hex color (0x00FF00)
            similarity: Color matching threshold (0.01 to 1.0)
            blend: Edge blending (0 to 1.0)
        """
        color_map = {
            "green": "0x00FF00",
            "blue": "0x0000FF",
            "red": "0xFF0000"
        }
        
        hex_color = color_map.get(color.lower(), color)
        
        filter_complex = (
            f"[0:v]chromakey={hex_color}:{similarity}:{blend}[fg];"
            f"[1:v][fg]overlay=format=auto"
        )
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-i", background_path,
            "-filter_complex", filter_complex,
            "-c:v", "libx264",
            "-c:a", "aac",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Chroma key failed: {e.stderr.decode()}")
    
    def stabilize_video(
        self,
        input_path: str,
        output_path: str,
        shakiness: int = 5,
        accuracy: int = 15
    ) -> str:
        """
        Stabilize shaky video (2-pass process)
        
        Args:
            shakiness: 1-10 (how shaky the video is)
            accuracy: 1-15 (detection accuracy)
        """
        import tempfile
        transforms_file = tempfile.NamedTemporaryFile(suffix=".trf", delete=False).name
        
        # Pass 1: Detect motion
        cmd1 = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", f"vidstabdetect=shakiness={shakiness}:accuracy={accuracy}:result={transforms_file}",
            "-f", "null", "-"
        ]
        
        # Pass 2: Apply stabilization
        cmd2 = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", f"vidstabtransform=input={transforms_file}:smoothing=10",
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd1, check=True, capture_output=True)
            subprocess.run(cmd2, check=True, capture_output=True)
            os.unlink(transforms_file)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Video stabilization failed: {e.stderr.decode()}")


# Singleton instance
effects_service = EffectsService()
