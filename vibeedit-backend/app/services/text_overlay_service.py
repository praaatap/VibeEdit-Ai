"""
Text Overlay Service - Professional text and graphics overlays
Animated captions, titles, watermarks, and graphics
"""
import subprocess
import os
from typing import Optional, List, Dict, Any
from pathlib import Path


class TextOverlayService:
    """
    Text and graphics overlay service for video editing
    """
    
    # Font styles
    FONTS = {
        "default": "Arial",
        "bold": "Arial-Bold",
        "modern": "Helvetica",
        "cinematic": "Georgia",
        "tech": "Consolas"
    }
    
    # Caption animation styles
    CAPTION_STYLES = {
        "default": {
            "fontsize": 24,
            "fontcolor": "white",
            "bordercolor": "black",
            "borderw": 2,
            "shadowcolor": "black@0.5",
            "shadowx": 2,
            "shadowy": 2
        },
        "bold": {
            "fontsize": 32,
            "fontcolor": "white",
            "bordercolor": "black",
            "borderw": 3
        },
        "viral": {
            "fontsize": 36,
            "fontcolor": "yellow",
            "bordercolor": "black",
            "borderw": 4
        },
        "cinematic": {
            "fontsize": 22,
            "fontcolor": "white@0.9",
            "bordercolor": "black@0.8",
            "borderw": 1
        },
        "neon": {
            "fontsize": 28,
            "fontcolor": "cyan",
            "bordercolor": "blue",
            "borderw": 2,
            "shadowcolor": "cyan@0.5",
            "shadowx": 0,
            "shadowy": 0
        }
    }
    
    def add_text(
        self,
        input_path: str,
        output_path: str,
        text: str,
        position: str = "center",
        fontsize: int = 48,
        fontcolor: str = "white",
        font: str = "Arial",
        start_time: float = 0,
        duration: Optional[float] = None,
        background: bool = False,
        bg_color: str = "black@0.5"
    ) -> str:
        """
        Add static text overlay to video
        
        Args:
            position: top, center, bottom, top-left, top-right, bottom-left, bottom-right
            fontsize: Font size in pixels
            fontcolor: Color name or hex
            start_time: When text appears (seconds)
            duration: How long text shows (None = entire video)
        """
        positions = {
            "center": "x=(w-text_w)/2:y=(h-text_h)/2",
            "top": "x=(w-text_w)/2:y=50",
            "bottom": "x=(w-text_w)/2:y=h-text_h-50",
            "top-left": "x=50:y=50",
            "top-right": "x=w-text_w-50:y=50",
            "bottom-left": "x=50:y=h-text_h-50",
            "bottom-right": "x=w-text_w-50:y=h-text_h-50"
        }
        
        pos = positions.get(position, positions["center"])
        
        # Build drawtext filter
        drawtext = (
            f"drawtext=text='{self._escape_text(text)}':"
            f"fontfile=/Windows/Fonts/arial.ttf:"
            f"fontsize={fontsize}:"
            f"fontcolor={fontcolor}:"
            f"{pos}"
        )
        
        if background:
            drawtext += f":box=1:boxcolor={bg_color}:boxborderw=5"
        
        # Add timing
        if start_time > 0 or duration is not None:
            enable_expr = f"enable='gte(t,{start_time})"
            if duration is not None:
                enable_expr += f"*lt(t,{start_time + duration})"
            enable_expr += "'"
            drawtext += f":{enable_expr}"
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", drawtext,
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Text overlay failed: {e.stderr.decode()}")
    
    def add_animated_text(
        self,
        input_path: str,
        output_path: str,
        text: str,
        animation: str = "fade-in",
        fontsize: int = 48,
        fontcolor: str = "white",
        position: str = "center",
        start_time: float = 0,
        duration: float = 3.0
    ) -> str:
        """
        Add animated text overlay
        
        Args:
            animation: fade-in, fade-out, slide-left, slide-right, slide-up, scale-in
        """
        positions = {
            "center": ("(w-text_w)/2", "(h-text_h)/2"),
            "top": ("(w-text_w)/2", "50"),
            "bottom": ("(w-text_w)/2", "h-text_h-50")
        }
        
        base_x, base_y = positions.get(position, positions["center"])
        
        # Animation expressions
        t_expr = f"(t-{start_time})"
        
        animations = {
            "fade-in": {
                "x": base_x,
                "y": base_y,
                "alpha": f"min(1,{t_expr}/0.5)"
            },
            "fade-out": {
                "x": base_x,
                "y": base_y,
                "alpha": f"max(0,1-({t_expr}-{duration-0.5})/0.5)"
            },
            "slide-left": {
                "x": f"w-mod(w*{t_expr}/2,w+text_w)",
                "y": base_y,
                "alpha": "1"
            },
            "slide-up": {
                "x": base_x,
                "y": f"h-mod(h*{t_expr}/3,h+text_h)",
                "alpha": "1"
            },
            "scale-in": {
                "x": base_x,
                "y": base_y,
                "alpha": "1",
                "fontsize": f"min({fontsize},{fontsize}*{t_expr}*2)"
            }
        }
        
        anim = animations.get(animation, animations["fade-in"])
        
        drawtext = (
            f"drawtext=text='{self._escape_text(text)}':"
            f"fontfile=/Windows/Fonts/arial.ttf:"
            f"fontsize={anim.get('fontsize', fontsize)}:"
            f"fontcolor={fontcolor}@'{anim['alpha']}':"
            f"x={anim['x']}:y={anim['y']}:"
            f"enable='between(t,{start_time},{start_time+duration})'"
        )
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vf", drawtext,
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Animated text failed: {e.stderr.decode()}")
    
    def add_captions(
        self,
        input_path: str,
        output_path: str,
        captions: List[Dict[str, Any]],
        style: str = "default"
    ) -> str:
        """
        Add timed captions/subtitles
        
        Args:
            captions: [{"start": 0, "end": 2.5, "text": "Hello"}]
            style: default, bold, viral, cinematic, neon
        """
        style_config = self.CAPTION_STYLES.get(style, self.CAPTION_STYLES["default"])
        
        # Build filter chain with multiple drawtext filters
        filters = []
        
        for caption in captions:
            text = self._escape_text(caption["text"])
            start = caption["start"]
            end = caption["end"]
            
            drawtext = (
                f"drawtext=text='{text}':"
                f"fontfile=/Windows/Fonts/arial.ttf:"
                f"fontsize={style_config['fontsize']}:"
                f"fontcolor={style_config['fontcolor']}:"
                f"bordercolor={style_config['bordercolor']}:"
                f"borderw={style_config['borderw']}:"
                f"x=(w-text_w)/2:y=h-text_h-60:"
                f"enable='between(t,{start},{end})'"
            )
            
            if 'shadowcolor' in style_config:
                drawtext += f":shadowcolor={style_config['shadowcolor']}:shadowx={style_config['shadowx']}:shadowy={style_config['shadowy']}"
            
            filters.append(drawtext)
        
        filter_chain = ",".join(filters) if filters else "null"
        
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
            raise Exception(f"Caption overlay failed: {e.stderr.decode()}")
    
    def add_watermark(
        self,
        input_path: str,
        watermark_path: str,
        output_path: str,
        position: str = "bottom-right",
        opacity: float = 0.7,
        scale: float = 0.15,
        margin: int = 20
    ) -> str:
        """
        Add image watermark/logo overlay
        
        Args:
            position: top-left, top-right, bottom-left, bottom-right, center
            opacity: 0.0 to 1.0
            scale: Size relative to video width (0.05 to 0.5)
            margin: Pixels from edge
        """
        positions = {
            "top-left": f"{margin}:{margin}",
            "top-right": f"main_w-overlay_w-{margin}:{margin}",
            "bottom-left": f"{margin}:main_h-overlay_h-{margin}",
            "bottom-right": f"main_w-overlay_w-{margin}:main_h-overlay_h-{margin}",
            "center": "(main_w-overlay_w)/2:(main_h-overlay_h)/2"
        }
        
        pos = positions.get(position, positions["bottom-right"])
        
        filter_complex = (
            f"[1:v]scale=iw*{scale}:-1,format=rgba,"
            f"colorchannelmixer=aa={opacity}[wm];"
            f"[0:v][wm]overlay={pos}"
        )
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-i", watermark_path,
            "-filter_complex", filter_complex,
            "-c:v", "libx264",
            "-c:a", "copy",
            "-preset", "fast",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Watermark overlay failed: {e.stderr.decode()}")
    
    def add_progress_bar(
        self,
        input_path: str,
        output_path: str,
        color: str = "red",
        height: int = 5,
        position: str = "bottom"
    ) -> str:
        """Add animated progress bar to video"""
        y_pos = "h-5" if position == "bottom" else "0"
        
        filter_complex = (
            f"drawbox=x=0:y={y_pos}:w=t/duration*iw:h={height}:"
            f"color={color}:t=fill"
        )
        
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
            raise Exception(f"Progress bar failed: {e.stderr.decode()}")
    
    def _escape_text(self, text: str) -> str:
        """Escape special characters for FFmpeg drawtext"""
        return (
            text
            .replace("\\", "\\\\")
            .replace("'", "'\\''")
            .replace(":", "\\:")
            .replace("%", "\\%")
        )


# Singleton instance
text_overlay_service = TextOverlayService()
