from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, List
import json
import os
from datetime import datetime, timedelta
import random
import math
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

class Doctor(BaseModel):
    id: str
    name: str
    specialty: str
    hospital: str
    lat: float
    lon: float
    phone: str
    rating: float

# Mock Doctor Database (India focus)
MOCK_DOCTORS = [
    Doctor(id="1", name="Dr. Rajesh Kumar", specialty="Cardiologist", hospital="Apollo Hospital, Delhi", lat=28.6139, lon=77.2090, phone="+91 98765 43210", rating=4.9),
    Doctor(id="2", name="Dr. Priya Singh", specialty="Neurologist", hospital="Max Super Specialty, Mumbai", lat=19.0760, lon=72.8777, phone="+91 98765 43211", rating=4.8),
    Doctor(id="3", name="Dr. Ananya Sharma", specialty="General Physician", hospital="Fortis Hospital, Bangalore", lat=12.9716, lon=77.5946, phone="+91 98765 43212", rating=4.7),
    Doctor(id="4", name="Dr. Vikram Sethi", specialty="Diabetologist", hospital="Continental Hospitals, Hyderabad", lat=17.3850, lon=78.4867, phone="+91 98765 43213", rating=4.9),
    Doctor(id="5", name="Dr. Smita Patil", specialty="Cardiologist", hospital="Nanavati Hospital, Mumbai", lat=19.1026, lon=72.8354, phone="+91 98765 43214", rating=4.8),
    Doctor(id="6", name="Dr. Amit Bhargava", specialty="Emergency Specialist", hospital="AIIMS, Delhi", lat=28.5672, lon=77.2100, phone="+91 98765 43215", rating=5.0),
]

def calculate_distance(lat1, lon1, lat2, lon2):
    R = 6371  # Earth radius in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2) * math.sin(dlat / 2) + \
        math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * \
        math.sin(dlon / 2) * math.sin(dlon / 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

@app.get("/doctors")
async def get_nearby_doctors(lat: float, lon: float, specialty: Optional[str] = None):
    nearby = []
    for doc in MOCK_DOCTORS:
        if specialty and specialty.lower() not in doc.specialty.lower():
            continue
        dist = calculate_distance(lat, lon, doc.lat, doc.lon)
        nearby.append({
            "doctor": doc.dict(),
            "distance_km": round(dist, 2)
        })
    # Sort by distance
    nearby.sort(key=lambda x: x["distance_km"])
    return nearby[:5]

@app.post("/login")
async def login(profile: UserProfile):
    email_safe = profile.email.replace("@", "_").replace(".", "_")
    profile_path = os.path.join(PROFILES_DIR, f"{email_safe}.json")
    
    with open(profile_path, "w") as f:
        json.dump(profile.dict(), f, indent=4)
        
    # Seed history if it doesn't exist
    history_path = os.path.join(HISTORY_DIR, f"{email_safe}.json")
    if not os.path.exists(history_path):
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
