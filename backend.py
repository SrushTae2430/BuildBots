from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import json
import os
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Enable CORS for Flutter web (if needed) and Streamlit
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_FILE = "user_profile.json"

class UserProfile(BaseModel):
    email: str
    age: int
    language: str
    gender: Optional[str] = "Prefer not to say"
    height: Optional[float] = None
    weight: Optional[float] = None
    lifestyle: Optional[str] = None
    smoking: Optional[str] = None
    alcohol: Optional[str] = None
    exercise: Optional[str] = None
    diet: Optional[str] = None
    sleep: Optional[str] = None
    stress: Optional[str] = None
    conditions: Optional[str] = None
    family_history: Optional[list] = []

@app.post("/login")
async def login(profile: UserProfile):
    with open(DB_FILE, "w") as f:
        json.dump(profile.dict(), f, indent=4)
    return {"message": "Profile synced successfully", "email": profile.email}

@app.get("/profile")
async def get_profile():
    if not os.path.exists(DB_FILE):
        raise HTTPException(status_code=404, detail="No profile found")
    with open(DB_FILE, "r") as f:
        data = json.load(f)
    return data

@app.post("/analyze-skin")
async def analyze_skin():
    # Placeholder for existing functionality
    return {
        "prediction": "Healthy",
        "confidence": 0.95,
        "recommendation": "Maintain your current skincare routine."
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
