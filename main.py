import tensorflow as tf
import numpy as np
import joblib
import pandas as pd
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from PIL import Image
import io

app = FastAPI(title="AI Healthcare Backend")

# ================= CORS =================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ================= LOAD MODELS =================
# Skin Disease Model (.keras)
try:
    skin_model = tf.keras.models.load_model("skin_disease_model.keras")
except Exception as e:
    print(f"Error loading skin model: {e}")
    skin_model = None

# Heart, Diabetes & Kidney Models (.pkl)
try:
    heart_model = joblib.load("models/heart_disease_model.pkl")
    diabetes_model = joblib.load("models/diabetes_model.pkl")
    kidney_model = joblib.load("models/kidney_model.pkl")
    # Identify expected features for Kidney model
    kidney_features = kidney_model.feature_names_in_.tolist()
except Exception as e:
    print(f"Error loading models: {e}")
    heart_model = None
    diabetes_model = None
    kidney_model = None
    kidney_features = []

# ================= SKIN CLASSES =================
classes = [
    "Eczema",
    "Psoriasis",
    "Acne",
    "Fungal Infection",
    "Melanoma",
    "Nevus",
    "Basal Cell Carcinoma",
    "Actinic Keratosis",
    "Benign Keratosis",
    "Vascular Lesion"
]

# ================= DATA MODELS =================
class HeartInput(BaseModel):
    age: int
    sex: int
    cp: int
    trestbps: int
    chol: int
    fbs: int
    restecg: int
    thalach: int
    exang: int
    oldpeak: float
    slope: int
    ca: int
    thal: int

class DiabetesInput(BaseModel):
    pregnancies: int
    glucose: float
    blood_pressure: float
    skin_thickness: float
    insulin: float
    bmi: float
    dpf: float
    age: int

class KidneyInput(BaseModel):
    id: float = 0
    age: float
    blood_pressure: float
    specific_gravity: float
    albumin: float
    sugar: float
    red_blood_cells: int
    pus_cell: int
    pus_cell_clumps: int
    bacteria: int
    blood_glucose_random: float
    blood_urea: float
    serum_creatinine: float
    sodium: float
    potassium: float
    hemoglobin: float
    packed_cell_volume: float
    white_blood_cell_count: float
    red_blood_cell_count: float
    hypertension: int
    diabetes_mellitus: int
    coronary_artery_disease: int
    appetite: int
    pedal_edema: int
    anaemia: int

# ================= HOME =================
@app.get("/")
def home():
    return {"message": "AI Healthcare Backend Running Successfully"}

# ================= SKIN ANALYSIS =================
@app.post("/analyze-skin")
async def analyze_skin(file: UploadFile = File(...)):
    if not skin_model:
        raise HTTPException(status_code=500, detail="Skin model not loaded")
    try:
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image = image.resize((224, 224))

        img_array = np.array(image) / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        predictions = skin_model.predict(img_array)
        predicted_index = np.argmax(predictions[0])
        confidence = float(np.max(predictions[0]))

        disease = classes[predicted_index]

        if disease in ["Melanoma", "Basal Cell Carcinoma", "Actinic Keratosis"]:
            risk = "High"
        elif disease in ["Psoriasis", "Fungal Infection"]:
            risk = "Medium"
        else:
            risk = "Low"

        return {
            "disease": disease,
            "risk_level": risk,
            "confidence": round(confidence, 4),
            "advice": "This is an AI screening result. Please consult a certified dermatologist."
        }

    except Exception as e:
        return {"error": str(e)}

# ================= HEART PREDICTION =================
@app.post("/predict/heart")
def predict_heart(data: HeartInput):
    if not heart_model:
        raise HTTPException(status_code=500, detail="Heart model not loaded")
    input_data = [list(data.model_dump().values())]
    features = np.array(input_data)
    risk = heart_model.predict_proba(features)[0][1]
    return {"heart_risk": float(risk)}

# ================= DIABETES PREDICTION =================
@app.post("/predict/diabetes")
def predict_diabetes(data: DiabetesInput):
    if not diabetes_model:
        raise HTTPException(status_code=500, detail="Diabetes model not loaded")
    input_data = [list(data.model_dump().values())]
    features = np.array(input_data)
    risk = diabetes_model.predict_proba(features)[0][1]
    return {"diabetes_risk": float(risk)}

# ================= KIDNEY PREDICTION =================
@app.post("/predict/kidney")
def predict_kidney(data: KidneyInput):
    if not kidney_model or not kidney_features:
        raise HTTPException(status_code=500, detail="Kidney model or features not loaded")
    
    try:
        input_dict = data.model_dump()
        # Create DataFrame and Reorder columns to match training
        input_df = pd.DataFrame([input_dict])[kidney_features]
        
        # Prediction
        risk_prob = kidney_model.predict_proba(input_df)[0][1]
        
        return {
            "kidney_risk": float(risk_prob),
            "status": "High Risk" if risk_prob > 0.5 else "Low Risk",
            "advice": "Please consult a nephrologist for clinical verification."
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))