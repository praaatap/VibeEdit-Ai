# VibeEdit AI Backend

AI-powered video editing API built with FastAPI.

## Quick Start

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run server
uvicorn app.main:app --reload
```

## API Endpoints

- `GET /health` - Health check
- `POST /api/auth/verify` - Verify Firebase token
- `POST /api/video/upload` - Upload video
- `POST /api/video/{id}/process` - Process video with AI
- `POST /api/ai/analyze` - Analyze video content

## Environment Variables

Copy `.env.example` to `.env` and configure:
- `OPENAI_API_KEY`
- `FIREBASE_CREDENTIALS_PATH`
- `CLOUD_STORAGE_BUCKET`
