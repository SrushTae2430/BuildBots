import joblib
import pandas as pd
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Enable CORS for mobile app connectivity
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# 1. Load the model
try:
    model = joblib.load("kidney_model.pkl")
    # This list ensures we send data in the EXACT order the model expects
    expected_features = model.feature_names_in_.tolist()
    print(f" Model Loaded. Expecting {len(expected_features)} features.")
except Exception as e:
    print(f" Error loading model: {e}")
    expected_features = []

# 2. Define the Schema for 25 Inputs
# Note: We use float/int to match the training data types
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

@app.post("/predict")
async def predict(data: KidneyInput):
    if not expected_features:
        raise HTTPException(status_code=500, detail="Model not loaded correctly.")

    try:
        # Convert incoming JSON data to a dictionary
        input_dict = data.model_dump()
        
        # Create a DataFrame and FORCE the column order to match the model
        input_df = pd.DataFrame([input_dict])[expected_features]
        
        # Perform Prediction
        # [0][1] gets the probability of '1' (Chronic Kidney Disease)
        risk_prob = model.predict_proba(input_df)[0][1]
        risk_percentage = round(float(risk_prob * 100), 2)
        
        # Determine Status and Recommendation
        status = "High Risk" if risk_percentage > 50 else "Normal"
        recommendation = (
            "Consult a Nephrologist immediately." 
            if risk_percentage > 50 else 
            "Maintain healthy hydration and diet."
        )

        return {
            "risk_score": risk_percentage,
            "status": status,
            "recommendation": recommendation
        }
        
    except Exception as e:
        print(f"Prediction Error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    # Make sure port 8080 is open on your firewall
    uvicorn.run(app, host="0.0.0.0", port=8080)