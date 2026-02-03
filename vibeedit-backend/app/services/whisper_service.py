"""
Whisper Service - Speech to text transcription
"""
from typing import Optional, List, Dict, Any
import tempfile
import os


class WhisperService:
    """
    Whisper service for speech-to-text transcription
    """
    
    def __init__(self, model_name: str = "base"):
        """Initialize Whisper model"""
        self.model = None
        self.model_name = model_name
        self._load_model()
    
    def _load_model(self):
        """Load Whisper model"""
        try:
            import whisper
            self.model = whisper.load_model(self.model_name)
            print(f"✅ Whisper model '{self.model_name}' loaded successfully")
        except Exception as e:
            print(f"⚠️ Whisper model loading failed: {e}")
            print("Whisper will run in demo mode")
    
    def transcribe(
        self,
        audio_path: str,
        language: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Transcribe audio file to text with timestamps
        
        Returns:
        {
            "text": "Full transcript",
            "segments": [
                {
                    "start": 0.0,
                    "end": 2.5,
                    "text": "Segment text"
                }
            ],
            "language": "en"
        }
        """
        if self.model is None:
            return self._get_demo_transcript()
        
        try:
            options = {}
            if language:
                options["language"] = language
            
            result = self.model.transcribe(audio_path, **options)
            
            return {
                "text": result["text"],
                "segments": [
                    {
                        "start": seg["start"],
                        "end": seg["end"],
                        "text": seg["text"].strip()
                    }
                    for seg in result["segments"]
                ],
                "language": result.get("language", "en")
            }
        except Exception as e:
            raise Exception(f"Transcription failed: {str(e)}")
    
    def transcribe_with_emotions(
        self,
        audio_path: str,
        language: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Transcribe audio and attempt basic emotion detection based on speech patterns
        """
        transcript = self.transcribe(audio_path, language)
        
        # Add emotion hints based on text patterns
        emotional_keywords = {
            "energetic": ["amazing", "awesome", "incredible", "excited", "wow", "!"],
            "emotional": ["feel", "heart", "love", "grateful", "thank", "blessed"],
            "motivational": ["can", "will", "believe", "achieve", "success", "dream"],
            "serious": ["important", "must", "need", "understand", "consider"],
            "funny": ["haha", "lol", "joke", "funny", "laugh"]
        }
        
        enriched_segments = []
        for segment in transcript["segments"]:
            text_lower = segment["text"].lower()
            
            # Simple emotion detection based on keywords
            detected_emotion = "calm"  # default
            max_matches = 0
            
            for emotion, keywords in emotional_keywords.items():
                matches = sum(1 for kw in keywords if kw in text_lower)
                if matches > max_matches:
                    max_matches = matches
                    detected_emotion = emotion
            
            enriched_segments.append({
                **segment,
                "emotion_hint": detected_emotion,
                "confidence": min(0.5 + (max_matches * 0.1), 0.9)
            })
        
        transcript["segments"] = enriched_segments
        transcript["emotion_analysis"] = True
        
        return transcript
    
    def get_captions(
        self,
        audio_path: str,
        max_chars_per_line: int = 42,
        language: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Generate caption-ready segments with proper line breaks
        """
        transcript = self.transcribe(audio_path, language)
        
        captions = []
        for segment in transcript["segments"]:
            text = segment["text"]
            
            # Split long text into multiple lines
            words = text.split()
            lines = []
            current_line = ""
            
            for word in words:
                if len(current_line) + len(word) + 1 <= max_chars_per_line:
                    current_line += (" " if current_line else "") + word
                else:
                    if current_line:
                        lines.append(current_line)
                    current_line = word
            
            if current_line:
                lines.append(current_line)
            
            captions.append({
                "start": segment["start"],
                "end": segment["end"],
                "text": "\n".join(lines),
                "original_text": text
            })
        
        return captions
    
    def _get_demo_transcript(self) -> Dict[str, Any]:
        """Return demo transcript when Whisper is not available"""
        return {
            "text": "This is a demo transcript. Connect Whisper for real transcription.",
            "segments": [
                {
                    "start": 0.0,
                    "end": 3.0,
                    "text": "This is a demo transcript."
                },
                {
                    "start": 3.0,
                    "end": 6.0,
                    "text": "Connect Whisper for real transcription."
                }
            ],
            "language": "en",
            "is_demo": True
        }


# Singleton instance
whisper_service = WhisperService()
