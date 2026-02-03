"""
LangChain Service - AI orchestration for video analysis
"""
from typing import Dict, List, Optional, Any
import json
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate
from langchain.schema import HumanMessage, SystemMessage

from app.core.config import settings


class LangChainService:
    """
    LangChain service for AI-powered video analysis and editing suggestions
    """
    
    SYSTEM_PROMPT = """You are VibeEdit AI, an expert AI video editor.

Your job is to transform long videos into short, viral-ready clips
optimized for Instagram Reels, YouTube Shorts, and TikTok.

Follow these rules strictly:
1. Identify the most engaging and high-retention moments.
2. Cut clips between 15–60 seconds.
3. Add concise, catchy captions with correct punctuation.
4. Preserve original meaning and emotions.
5. Avoid unnecessary cuts or silence.
6. Output clear editing instructions including:
   - timestamps
   - caption text
   - aspect ratio
   - tone (viral, cinematic, educational)
7. Prioritize viewer attention in the first 3 seconds.

EMOTIONAL INTELLIGENCE RULES:
- Detect emotion in speech (Excited, Sad, Motivational, Serious)
- Match edit style to emotion:
  - Emotional → softer cuts, slower pace
  - Energetic → fast cuts, bold captions
- Never change the original meaning
- Avoid embarrassing cuts
- Respect sensitive content

Be precise, creative, and creator-focused.
Preserve creator's emotion over virality."""

    CREATOR_SUPPORT_PROMPT = """CREATOR SUPPORT MODE ENABLED:
- Give gentle, encouraging feedback
- Less aggressive edits
- More respectful captions
- Preserve authenticity over virality
- Handle personal stories with care
- Focus on emotional resonance"""

    def __init__(self):
        """Initialize LangChain with OpenAI"""
        self.llm = None
        if settings.OPENAI_API_KEY:
            try:
                self.llm = ChatOpenAI(
                    api_key=settings.OPENAI_API_KEY,
                    model="gpt-4-turbo-preview",
                    temperature=0.7
                )
            except Exception as e:
                print(f"⚠️ OpenAI initialization error: {e}")
    
    def get_system_prompt(self) -> str:
        """Get the system prompt"""
        return self.SYSTEM_PROMPT
    
    async def analyze_transcript(
        self,
        transcript: str,
        platform: str = "instagram_reels",
        tone: str = "viral",
        clip_count: int = 3,
        creator_support_mode: bool = False
    ) -> Dict[str, Any]:
        """
        Analyze transcript and suggest clips
        """
        system_prompt = self.SYSTEM_PROMPT
        if creator_support_mode:
            system_prompt += "\n\n" + self.CREATOR_SUPPORT_PROMPT
        
        human_prompt = f"""Analyze this video transcript and suggest {clip_count} clips for {platform}.

Target tone: {tone}
Platform: {platform}

Transcript:
{transcript}

Respond in JSON format:
{{
    "clips": [
        {{
            "start_timestamp": "MM:SS",
            "end_timestamp": "MM:SS", 
            "caption": "Short caption for the clip",
            "hook": "Attention-grabbing opening line",
            "engagement_reason": "Why this moment is engaging",
            "emotion": "energetic|emotional|motivational|serious|funny|calm",
            "confidence_score": 0.0-1.0
        }}
    ],
    "overall_emotion": "dominant emotion",
    "content_summary": "Brief summary of the video content",
    "creator_feedback": "Encouraging feedback for the creator",
    "tips": ["Tip 1", "Tip 2"]
}}"""

        if self.llm:
            try:
                messages = [
                    SystemMessage(content=system_prompt),
                    HumanMessage(content=human_prompt)
                ]
                response = await self.llm.ainvoke(messages)
                result = json.loads(response.content)
                return result
            except Exception as e:
                print(f"LangChain error: {e}")
        
        # Fallback demo response
        return self._get_demo_analysis(clip_count, tone)
    
    async def detect_emotions(
        self,
        transcript: str,
        include_timestamps: bool = False
    ) -> Dict[str, Any]:
        """
        Detect emotions in transcript segments
        """
        human_prompt = f"""Analyze the emotional content of this transcript.
Break it into segments and identify the emotion in each.

Transcript:
{transcript}

Respond in JSON format:
{{
    "segments": [
        {{
            "text": "segment text",
            "emotion": "energetic|emotional|motivational|serious|funny|calm",
            "confidence": 0.0-1.0
        }}
    ],
    "dominant_emotion": "overall dominant emotion",
    "emotion_summary": "Brief description of emotional journey"
}}"""

        if self.llm:
            try:
                messages = [
                    SystemMessage(content=self.SYSTEM_PROMPT),
                    HumanMessage(content=human_prompt)
                ]
                response = await self.llm.ainvoke(messages)
                return json.loads(response.content)
            except Exception as e:
                print(f"Emotion detection error: {e}")
        
        # Fallback
        return {
            "segments": [
                {
                    "text": transcript[:100] + "...",
                    "emotion": "motivational",
                    "confidence": 0.85
                }
            ],
            "dominant_emotion": "motivational",
            "emotion_summary": "The content has an uplifting, motivational tone throughout."
        }
    
    async def generate_clip_suggestions(
        self,
        video_id: str,
        transcript: str,
        platform: str = "instagram_reels",
        tone: str = "viral",
        clip_count: int = 3,
        custom_prompt: Optional[str] = None,
        creator_support_mode: bool = False
    ) -> Dict[str, Any]:
        """
        Generate clip suggestions with optional custom prompt
        """
        base_prompt = f"""Generate {clip_count} clip suggestions for {platform}.
Tone: {tone}"""
        
        if custom_prompt:
            base_prompt += f"\n\nCreator's request: {custom_prompt}"
        
        base_prompt += f"\n\nTranscript:\n{transcript}"
        
        system = self.SYSTEM_PROMPT
        if creator_support_mode:
            system += "\n\n" + self.CREATOR_SUPPORT_PROMPT
        
        if self.llm:
            try:
                messages = [
                    SystemMessage(content=system),
                    HumanMessage(content=base_prompt)
                ]
                response = await self.llm.ainvoke(messages)
                return json.loads(response.content)
            except Exception as e:
                print(f"Clip generation error: {e}")
        
        return self._get_demo_analysis(clip_count, tone)
    
    def _get_demo_analysis(self, clip_count: int, tone: str) -> Dict[str, Any]:
        """Get demo analysis response when AI is not available"""
        clips = []
        for i in range(clip_count):
            clips.append({
                "start_timestamp": f"0{i}:00",
                "end_timestamp": f"0{i}:30",
                "caption": f"This moment is pure gold ✨ #{tone}",
                "hook": "Wait for it... 👀",
                "engagement_reason": "High energy moment with emotional impact",
                "emotion": "energetic" if tone == "viral" else tone,
                "confidence_score": 0.85 - (i * 0.1)
            })
        
        return {
            "clips": clips,
            "overall_emotion": "motivational",
            "content_summary": "Demo analysis - connect OpenAI API for real results",
            "creator_feedback": "Your content has amazing potential! 🌟 These moments really stand out.",
            "tips": [
                "Strong hook in the first 3 seconds",
                "Great emotional resonance throughout",
                "Consider adding trending audio for extra reach"
            ]
        }
