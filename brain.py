from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import joblib
import os
import uvicorn

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

MODEL_FILE = "kidney_model.pkl"
DATA_PATH = "kidney_disease.csv"

class PatientData(BaseModel):
    age: float
    sc: float
    htn: int
    dm: int

def train_or_load_model():
    if os.path.exists(MODEL_FILE):
        return joblib.load(MODEL_FILE)
    
    print(">>> TRAINING MODEL...")
    df = pd.read_csv(DATA_PATH)
    features = ['age', 'sc', 'htn', 'dm']
    
    # Data Normalization
    df['dm'] = df['dm'].astype(str).str.strip().str.lower().replace({'yes': 1, 'no': 0})
    df['htn'] = df['htn'].astype(str).str.strip().str.lower().replace({'yes': 1, 'no': 0})
    df['classification'] = df['classification'].astype(str).str.strip().str.lower().replace({'ckd': 1, 'notckd': 0})
    
    df = df[features + ['classification']].apply(pd.to_numeric, errors='coerce')
    df = df.fillna(df.median())

    model = RandomForestClassifier(n_estimators=200, class_weight='balanced', random_state=42)
    model.fit(df[features], df['classification'])
    
    joblib.dump(model, MODEL_FILE)
    return model

clf = train_or_load_model()

@app.post("/predict")
async def predict(data: PatientData):
    try:
        # Fixed: Use DataFrame to provide feature names to the model
        input_df = pd.DataFrame([[data.age, data.sc, data.htn, data.dm]], 
                                columns=['age', 'sc', 'htn', 'dm'])
        
        prob = clf.predict_proba(input_df)[0][1]
        
        # Clinical Override for High Creatinine
        if data.sc > 1.4: prob = max(prob, 0.75)
        if data.sc > 3.0: prob = 0.99

        return {"risk_score": round(float(prob * 100), 2)}
    except Exception as e:
        return {"error": str(e), "risk_score": 0.0}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)