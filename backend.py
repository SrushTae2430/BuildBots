from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import json
import os
from datetime import datetime, timedelta
import random
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATA_DIR = "data"
PROFILES_DIR = os.path.join(DATA_DIR, "profiles")
HISTORY_DIR = os.path.join(DATA_DIR, "history")

os.makedirs(PROFILES_DIR, exist_ok=True)
os.makedirs(HISTORY_DIR, exist_ok=True)

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
    medical_conditions: Optional[str] = None
    family_history: Optional[List[str]] = []

@app.post("/login")
async def login(profile: UserProfile):
    email_safe = profile.email.replace("@", "_").replace(".", "_")
    profile_path = os.path.join(PROFILES_DIR, f"{email_safe}.json")
    
    with open(profile_path, "w") as f:
        json.dump(profile.dict(), f, indent=4)
        
    # Seed history if it doesn't exist
    history_path = os.path.join(HISTORY_DIR, f"{email_safe}.json")
    if not os.path.exists(history_path):
        # Generate 12 months of synthetic data
        history = []
        base_risk = random.uniform(3.0, 5.0)
        for i in range(12):
            date = (datetime.now() - timedelta(days=30*i)).strftime("%Y-%m-%d")
            risk = max(1.0, min(10.0, base_risk + random.uniform(-0.5, 0.5)))
            history.append({
                "date": date,
                "risk": round(float(risk), 1),
                "stability": random.choice(["Stable", "Fluctuating", "Critical"])
            })
        with open(history_path, "w") as f:
            json.dump(history, f, indent=4)

    return {"message": "Profile synced successfully", "email": profile.email}

@app.get("/profile")
async def get_profile(email: Optional[str] = None):
    if not email:
        files = [f for f in os.listdir(PROFILES_DIR) if f.endswith(".json")]
        if not files:
            raise HTTPException(status_code=404, detail="No profiles found")
        email_safe = files[0].replace(".json", "")
    else:
        email_safe = email.replace("@", "_").replace(".", "_")
    
    profile_path = os.path.join(PROFILES_DIR, f"{email_safe}.json")
    if not os.path.exists(profile_path):
        raise HTTPException(status_code=404, detail="User not found")
        
    with open(profile_path, "r") as f:
        return json.load(f)

@app.get("/history")
async def get_history(email: str):
    email_safe = email.replace("@", "_").replace(".", "_")
    history_path = os.path.join(HISTORY_DIR, f"{email_safe}.json")
    
    if not os.path.exists(history_path):
        return []
        
    with open(history_path, "r") as f:
        return json.load(f)

@app.post("/add-vitals")
async def add_vitals(email: str, risk: float, stability: str):
    email_safe = email.replace("@", "_").replace(".", "_")
    history_path = os.path.join(HISTORY_DIR, f"{email_safe}.json")
    
    history = []
    if os.path.exists(history_path):
        with open(history_path, "r") as f:
            history = json.load(f)
            
    history.insert(0, {
        "date": datetime.now().strftime("%Y-%m-%d"),
        "risk": risk,
        "stability": stability
    })
    
    # Keep last 24 entries
    history = history[:24]
    
    with open(history_path, "w") as f:
        json.dump(history, f, indent=4)
        
    return {"status": "success"}

@app.post("/analyze-skin")
async def analyze_skin():
    return {
        "prediction": "Healthy",
        "confidence": 0.95,
        "recommendation": "Maintain your current skincare routine."
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
