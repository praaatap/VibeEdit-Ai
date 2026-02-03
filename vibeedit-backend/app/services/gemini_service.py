"""
Google Gemini AI Service - Alternative AI provider
Video analysis, content generation, and smart editing suggestions
"""
from typing import Dict, List, Optional, Any
import json
import os

from app.core.config import settings


class GeminiService:
    """
    Google Gemini AI service for video analysis and content generation
    """
    
    SYSTEM_PROMPT = """You are VibeEdit AI, an expert AI video editor powered by Google Gemini.

Your capabilities:
1. Analyze video content and suggest optimal edit points
2. Generate engaging captions and titles
3. Detect scenes and emotions
4. Suggest thumbnails
5. Create content for multiple platforms

Output format for clip suggestions:
{
    "clips": [
        {
            "start_time": "MM:SS",
            "end_time": "MM:SS",
            "caption": "Short catchy caption",
            "hook": "Opening hook text",
            "engagement_score": 0.0-1.0,
            "emotion": "energetic|emotional|motivational|serious|funny|calm",
            "reason": "Why this moment is engaging"
        }
    ],
    "title_suggestions": ["Title 1", "Title 2"],
    "hashtags": ["#hashtag1", "#hashtag2"],
    "thumbnail_timestamps": [0.0, 10.5, 25.0]
}

Be creative, engaging, and platform-aware."""
    
    def __init__(self):
        """Initialize Gemini AI"""
        self.model = None
        self._initialize()
    
    def _initialize(self):
        """Initialize Gemini model"""
        if settings.GOOGLE_API_KEY:
            try:
                import google.generativeai as genai
                genai.configure(api_key=settings.GOOGLE_API_KEY)
                self.model = genai.GenerativeModel('gemini-pro')
                print("✅ Gemini AI initialized successfully")
            except Exception as e:
                print(f"⚠️ Gemini initialization failed: {e}")
    
    async def analyze_transcript(
        self,
        transcript: str,
        platform: str = "instagram_reels",
        tone: str = "viral",
        clip_count: int = 3
    ) -> Dict[str, Any]:
        """Analyze transcript and suggest clips"""
        prompt = f"""Analyze this video transcript and suggest {clip_count} clips for {platform}.

Target tone: {tone}
Platform: {platform}

Transcript:
{transcript}

Respond with JSON containing:
- clips: Array of clip suggestions with start_time, end_time, caption, hook, engagement_score, emotion, reason
- title_suggestions: 3 catchy titles
- hashtags: Relevant hashtags
- thumbnail_timestamps: Best frames for thumbnails (seconds)
- content_summary: Brief summary
- tips: 3 improvement tips"""

        if self.model:
            try:
                response = await self._generate(prompt)
                return self._parse_json_response(response)
            except Exception as e:
                print(f"Gemini analysis error: {e}")
        
        return self._get_demo_response(clip_count, tone)
    
    async def detect_scenes(
        self,
        transcript: str,
        visual_descriptions: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """Detect scene changes and suggest cut points"""
        prompt = f"""Analyze this content and identify distinct scenes or segments.

Transcript:
{transcript}

For each scene, identify:
- Start and end timestamps (MM:SS format)
- Scene description
- Suggested action (keep, cut, highlight)
- Emotion/mood

Respond with JSON:
{{
    "scenes": [
        {{
            "start": "MM:SS",
            "end": "MM:SS",
            "description": "Brief description",
            "action": "keep|cut|highlight",
            "mood": "energetic|calm|emotional|etc"
        }}
    ],
    "total_scenes": number,
    "highlight_scenes": [scene indices]
}}"""

        if self.model:
            try:
                response = await self._generate(prompt)
                return self._parse_json_response(response)
            except Exception as e:
                print(f"Scene detection error: {e}")
        
        return {
            "scenes": [
                {
                    "start": "00:00",
                    "end": "01:00",
                    "description": "Opening segment",
                    "action": "keep",
                    "mood": "energetic"
                }
            ],
            "total_scenes": 1,
            "highlight_scenes": [0]
        }
    
    async def generate_captions(
        self,
        transcript: str,
        style: str = "viral",
        max_chars: int = 100
    ) -> Dict[str, Any]:
        """Generate styled captions from transcript"""
        prompt = f"""Transform this transcript into engaging {style} captions.

Rules:
- Max {max_chars} characters per caption
- Add emoji where appropriate
- Make them punchy and attention-grabbing
- Preserve original meaning

Transcript:
{transcript}

Respond with JSON:
{{
    "captions": [
        {{
            "original": "Original text segment",
            "styled": "Styled caption version",
            "emoji": "Relevant emoji"
        }}
    ]
}}"""

        if self.model:
            try:
                response = await self._generate(prompt)
                return self._parse_json_response(response)
            except Exception as e:
                print(f"Caption generation error: {e}")
        
        return {
            "captions": [
                {
                    "original": transcript[:100],
                    "styled": f"✨ {transcript[:80]}...",
                    "emoji": "✨"
                }
            ]
        }
    
    async def suggest_music(
        self,
        transcript: str,
        duration: float,
        mood: Optional[str] = None
    ) -> Dict[str, Any]:
        """Suggest background music based on content"""
        prompt = f"""Based on this video content, suggest appropriate background music.

Duration: {duration} seconds
{"Mood: " + mood if mood else ""}

Transcript:
{transcript[:500]}

Suggest music with:
- Genre
- Tempo (BPM range)
- Energy level
- Mood keywords
- Specific song recommendations (royalty-free)

Respond with JSON:
{{
    "suggestions": [
        {{
            "genre": "Genre name",
            "tempo": "slow|medium|fast",
            "bpm_range": "80-100",
            "mood": ["keyword1", "keyword2"],
            "example_songs": ["Song 1", "Song 2"],
            "reason": "Why this fits"
        }}
    ],
    "primary_mood": "Main mood detected",
    "energy_profile": "How energy changes through video"
}}"""

        if self.model:
            try:
                response = await self._generate(prompt)
                return self._parse_json_response(response)
            except Exception as e:
                print(f"Music suggestion error: {e}")
        
        return {
            "suggestions": [
                {
                    "genre": "Electronic/Chill",
                    "tempo": "medium",
                    "bpm_range": "100-120",
                    "mood": ["uplifting", "motivational"],
                    "example_songs": ["Inspiring Corporate", "Upbeat Technology"],
                    "reason": "Matches content energy"
                }
            ],
            "primary_mood": "motivational",
            "energy_profile": "Steady energy throughout"
        }
    
    async def generate_titles_descriptions(
        self,
        transcript: str,
        platform: str = "youtube"
    ) -> Dict[str, Any]:
        """Generate SEO-optimized titles and descriptions"""
        prompt = f"""Create SEO-optimized titles and descriptions for {platform}.

Content:
{transcript[:1000]}

Generate:
- 5 catchy titles (different styles)
- SEO-optimized description
- Relevant tags/keywords
- Hook for first 3 seconds

Respond with JSON:
{{
    "titles": [
        {{"text": "Title", "style": "clickbait|professional|emotional|etc"}}
    ],
    "description": "Full SEO description...",
    "tags": ["tag1", "tag2"],
    "hook": "Opening hook text",
    "cta": "Call to action text"
}}"""

        if self.model:
            try:
                response = await self._generate(prompt)
                return self._parse_json_response(response)
            except Exception as e:
                print(f"Title generation error: {e}")
        
        return {
            "titles": [
                {"text": "Amazing Content You Need to See", "style": "clickbait"},
                {"text": "Professional Guide", "style": "professional"}
            ],
            "description": "Check out this amazing content...",
            "tags": ["viral", "trending", "content"],
            "hook": "You won't believe what happens next...",
            "cta": "Like and subscribe for more!"
        }
    
    async def moderate_content(
        self,
        transcript: str
    ) -> Dict[str, Any]:
        """Check content for policy violations"""
        prompt = f"""Analyze this content for potential policy violations.

Check for:
- Inappropriate language
- Harmful content
- Copyright concerns
- Platform policy violations

Content:
{transcript}

Respond with JSON:
{{
    "is_safe": true/false,
    "confidence": 0.0-1.0,
    "flags": [
        {{
            "type": "language|violence|copyright|etc",
            "severity": "low|medium|high",
            "description": "Issue description",
            "timestamp": "Approximate location if applicable"
        }}
    ],
    "recommendations": ["Recommendation 1", "Recommendation 2"]
}}"""

        if self.model:
            try:
                response = await self._generate(prompt)
                return self._parse_json_response(response)
            except Exception as e:
                print(f"Content moderation error: {e}")
        
        return {
            "is_safe": True,
            "confidence": 0.95,
            "flags": [],
            "recommendations": []
        }
    
    async def _generate(self, prompt: str) -> str:
        """Generate response from Gemini"""
        if not self.model:
            raise Exception("Gemini not initialized")
        
        full_prompt = f"{self.SYSTEM_PROMPT}\n\n{prompt}"
        response = self.model.generate_content(full_prompt)
        return response.text
    
    def _parse_json_response(self, response: str) -> Dict[str, Any]:
        """Parse JSON from AI response"""
        try:
            # Find JSON in response
            start = response.find('{')
            end = response.rfind('}') + 1
            if start >= 0 and end > start:
                return json.loads(response[start:end])
        except json.JSONDecodeError:
            pass
        
        return {"raw_response": response}
    
    def _get_demo_response(self, clip_count: int, tone: str) -> Dict[str, Any]:
        """Demo response when AI is unavailable"""
        clips = []
        for i in range(clip_count):
            clips.append({
                "start_time": f"0{i}:00",
                "end_time": f"0{i}:30",
                "caption": f"Amazing moment #{i+1} ✨",
                "hook": "Wait for it... 👀",
                "engagement_score": 0.85 - (i * 0.1),
                "emotion": "energetic" if tone == "viral" else tone,
                "reason": "High engagement potential"
            })
        
        return {
            "clips": clips,
            "title_suggestions": [
                "🔥 This Will Blow Your Mind",
                "You Need to See This!",
                "The Ultimate Guide"
            ],
            "hashtags": ["#viral", "#trending", "#fyp"],
            "thumbnail_timestamps": [0, 15, 30],
            "content_summary": "Demo analysis - connect Google API for real results",
            "tips": [
                "Strong hook in first 3 seconds",
                "Add trending audio",
                "Use dynamic captions"
            ]
        }


# Singleton instance
gemini_service = GeminiService()
