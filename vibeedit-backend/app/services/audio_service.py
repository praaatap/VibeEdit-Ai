"""
Audio Service - Professional audio processing using FFmpeg
Background music, mixing, noise reduction, effects
"""
import subprocess
import os
from typing import Optional, List, Dict, Any
from pathlib import Path


class AudioService:
    """
    Audio processing service for video editing
    """
    
    def extract_audio(
        self,
        input_path: str,
        output_path: str,
        format: str = "mp3"
    ) -> str:
        """Extract audio track from video"""
        codec_map = {
            "mp3": "libmp3lame",
            "aac": "aac",
            "wav": "pcm_s16le",
            "flac": "flac"
        }
        
        codec = codec_map.get(format, "libmp3lame")
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-vn",
            "-acodec", codec,
            "-ar", "44100",
            "-ac", "2",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Audio extraction failed: {e.stderr.decode()}")
    
    def add_background_music(
        self,
        video_path: str,
        music_path: str,
        output_path: str,
        music_volume: float = 0.3,
        original_volume: float = 1.0,
        fade_in: float = 0,
        fade_out: float = 0
    ) -> str:
        """
        Add background music to video
        
        Args:
            music_volume: 0.0 to 1.0 (relative volume of music)
            original_volume: 0.0 to 1.0 (relative volume of original audio)
            fade_in: Seconds of fade in for music
            fade_out: Seconds of fade out for music
        """
        # Build audio filter
        music_filters = [f"volume={music_volume}"]
        
        if fade_in > 0:
            music_filters.append(f"afade=t=in:st=0:d={fade_in}")
        
        # Get video duration for fade out
        if fade_out > 0:
            duration = self._get_duration(video_path)
            fade_start = max(0, duration - fade_out)
            music_filters.append(f"afade=t=out:st={fade_start}:d={fade_out}")
        
        music_filter_chain = ",".join(music_filters)
        
        filter_complex = (
            f"[0:a]volume={original_volume}[orig];"
            f"[1:a]{music_filter_chain}[music];"
            f"[orig][music]amix=inputs=2:duration=first[aout]"
        )
        
        cmd = [
            "ffmpeg", "-y",
            "-i", video_path,
            "-i", music_path,
            "-filter_complex", filter_complex,
            "-map", "0:v",
            "-map", "[aout]",
            "-c:v", "copy",
            "-c:a", "aac",
            "-shortest",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Background music addition failed: {e.stderr.decode()}")
    
    def replace_audio(
        self,
        video_path: str,
        audio_path: str,
        output_path: str
    ) -> str:
        """Replace video audio track completely"""
        cmd = [
            "ffmpeg", "-y",
            "-i", video_path,
            "-i", audio_path,
            "-map", "0:v",
            "-map", "1:a",
            "-c:v", "copy",
            "-c:a", "aac",
            "-shortest",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Audio replacement failed: {e.stderr.decode()}")
    
    def remove_audio(self, input_path: str, output_path: str) -> str:
        """Remove audio track from video"""
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-an",
            "-c:v", "copy",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Audio removal failed: {e.stderr.decode()}")
    
    def adjust_volume(
        self,
        input_path: str,
        output_path: str,
        volume: float = 1.0
    ) -> str:
        """
        Adjust audio volume
        
        Args:
            volume: 0.0 to 3.0 (1.0 = no change, 2.0 = double)
        """
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-af", f"volume={volume}",
            "-c:v", "copy",
            "-c:a", "aac",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Volume adjustment failed: {e.stderr.decode()}")
    
    def normalize_audio(
        self,
        input_path: str,
        output_path: str,
        target_level: float = -14.0
    ) -> str:
        """
        Normalize audio levels (loudness normalization)
        
        Args:
            target_level: Target loudness in LUFS (-23 to -5)
        """
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-af", f"loudnorm=I={target_level}:TP=-1.5:LRA=11",
            "-c:v", "copy",
            "-c:a", "aac",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Audio normalization failed: {e.stderr.decode()}")
    
    def reduce_noise(
        self,
        input_path: str,
        output_path: str,
        noise_reduction: float = 0.21,
        noise_floor: float = -30
    ) -> str:
        """
        Reduce background noise in audio
        
        Args:
            noise_reduction: 0 to 1 (amount of noise to remove)
            noise_floor: dB threshold for noise detection
        """
        # Using highpass and lowpass filters + noise gate for basic noise reduction
        filter_chain = (
            f"highpass=f=80,"  # Remove rumble
            f"lowpass=f=12000,"  # Remove hiss
            f"afftdn=nf={noise_floor}:nr={noise_reduction*100}"  # FFT denoise
        )
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-af", filter_chain,
            "-c:v", "copy",
            "-c:a", "aac",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Noise reduction failed: {e.stderr.decode()}")
    
    def add_audio_fade(
        self,
        input_path: str,
        output_path: str,
        fade_in: float = 0,
        fade_out: float = 0
    ) -> str:
        """Add fade in/out effects to audio"""
        filters = []
        
        if fade_in > 0:
            filters.append(f"afade=t=in:st=0:d={fade_in}")
        
        if fade_out > 0:
            duration = self._get_duration(input_path)
            fade_start = max(0, duration - fade_out)
            filters.append(f"afade=t=out:st={fade_start}:d={fade_out}")
        
        if not filters:
            filters.append("anull")
        
        filter_chain = ",".join(filters)
        
        cmd = [
            "ffmpeg", "-y",
            "-i", input_path,
            "-af", filter_chain,
            "-c:v", "copy",
            "-c:a", "aac",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Audio fade failed: {e.stderr.decode()}")
    
    def mix_audio_tracks(
        self,
        input_path: str,
        audio_tracks: List[Dict[str, Any]],
        output_path: str
    ) -> str:
        """
        Mix multiple audio tracks with individual volume controls
        
        Args:
            audio_tracks: [{"path": "audio.mp3", "volume": 0.5, "start": 0}]
        """
        inputs = ["-i", input_path]
        filter_parts = ["[0:a]volume=1.0[a0]"]
        mix_inputs = "[a0]"
        
        for i, track in enumerate(audio_tracks, 1):
            inputs.extend(["-i", track["path"]])
            volume = track.get("volume", 1.0)
            start = track.get("start", 0)
            
            if start > 0:
                filter_parts.append(f"[{i}:a]adelay={int(start*1000)}|{int(start*1000)},volume={volume}[a{i}]")
            else:
                filter_parts.append(f"[{i}:a]volume={volume}[a{i}]")
            
            mix_inputs += f"[a{i}]"
        
        num_inputs = len(audio_tracks) + 1
        filter_parts.append(f"{mix_inputs}amix=inputs={num_inputs}:duration=longest[aout]")
        filter_complex = ";".join(filter_parts)
        
        cmd = [
            "ffmpeg", "-y",
            *inputs,
            "-filter_complex", filter_complex,
            "-map", "0:v",
            "-map", "[aout]",
            "-c:v", "copy",
            "-c:a", "aac",
            output_path
        ]
        
        try:
            subprocess.run(cmd, check=True, capture_output=True)
            return output_path
        except subprocess.CalledProcessError as e:
            raise Exception(f"Audio mixing failed: {e.stderr.decode()}")
    
    def _get_duration(self, input_path: str) -> float:
        """Get media duration in seconds"""
        import json
        
        cmd = [
            "ffprobe",
            "-v", "quiet",
            "-print_format", "json",
            "-show_format",
            input_path
        ]
        
        try:
            result = subprocess.run(cmd, check=True, capture_output=True)
            data = json.loads(result.stdout)
            return float(data["format"]["duration"])
        except:
            return 0


# Singleton instance
audio_service = AudioService()
