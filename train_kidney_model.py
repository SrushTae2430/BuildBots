import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.impute import SimpleImputer
from sklearn.metrics import accuracy_score
import joblib
import requests
import os

# ────────────────────────────────────────────────
#  Download dataset if not already present
# ────────────────────────────────────────────────
url = "https://raw.githubusercontent.com/mansoordaku/CKD-dataset/master/kidney_disease.csv"
filename = "kidney_disease.csv"

if not os.path.exists(filename):
    print("Downloading dataset...")
    response = requests.get(url)
    if response.status_code == 200:
        with open(filename, 'wb') as f:
            f.write(response.content)
        print("Dataset downloaded.")
    else:
        print("Download failed. Please download manually from:")
        print("https://www.kaggle.com/datasets/mansoordaku/ckdisease")
        print("and place kidney_disease.csv in this folder.")
        exit()

# ────────────────────────────────────────────────
#  Load and prepare data
# ────────────────────────────────────────────────
df = pd.read_csv(filename)

# Rename columns to standard short names (common in many projects)
df = df.rename(columns={
    'bp': 'blood_pressure',
    'sg': 'specific_gravity',
    'al': 'albumin',
    'su': 'sugar',
    'rbc': 'red_blood_cells',
    'pc': 'pus_cell',
    'pcc': 'pus_cell_clumps',
    'ba': 'bacteria',
    'bgr': 'blood_glucose_random',
    'bu': 'blood_urea',
    'sc': 'serum_creatinine',
    'sod': 'sodium',
    'pot': 'potassium',
    'hemo': 'hemoglobin',
    'pcv': 'packed_cell_volume',
    'wc': 'white_blood_cell_count',
    'rc': 'red_blood_cell_count',
    'htn': 'hypertension',
    'dm': 'diabetes_mellitus',
    'cad': 'coronary_artery_disease',
    'appet': 'appetite',
    'pe': 'pedal_edema',
    'ane': 'anaemia',
    'classification': 'target'
})

# Clean target (very common issue)
df['target'] = df['target'].replace(['ckd\t', 'ckd', 'notckd'], ['ckd', 'ckd', 'notckd'])
df['target'] = df['target'].map({'ckd': 1, 'notckd': 0})

# Replace '?' with NaN
df = df.replace('?', np.nan)

# Convert numeric-looking object columns to float
numeric_cols = ['age', 'blood_pressure', 'specific_gravity', 'albumin', 'sugar',
                'blood_glucose_random', 'blood_urea', 'serum_creatinine', 'sodium',
                'potassium', 'hemoglobin', 'packed_cell_volume',
                'white_blood_cell_count', 'red_blood_cell_count']

for col in numeric_cols:
    if col in df.columns:
        df[col] = pd.to_numeric(df[col], errors='coerce')

# ────────────────────────────────────────────────
#  Simple preprocessing
# ────────────────────────────────────────────────
# Fill missing values
num_imputer = SimpleImputer(strategy='median')
cat_imputer = SimpleImputer(strategy='most_frequent')

num_features = df.select_dtypes(include=np.number).columns.drop('target', errors='ignore')
cat_features = df.select_dtypes(exclude=np.number).columns

df[num_features] = num_imputer.fit_transform(df[num_features])
df[cat_features] = cat_imputer.fit_transform(df[cat_features])

# Label encode categorical columns
le = LabelEncoder()
for col in cat_features:
    df[col] = le.fit_transform(df[col].astype(str))

# ────────────────────────────────────────────────
#  Split & Train
# ────────────────────────────────────────────────
X = df.drop('target', axis=1)
y = df['target']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)

model = RandomForestClassifier(
    n_estimators=100,
    max_depth=10,
    random_state=42,
    n_jobs=-1
)

model.fit(X_train, y_train)

# Quick check
preds = model.predict(X_test)
acc = accuracy_score(y_test, preds)
print(f"Model accuracy on test set: {acc:.4f} ({acc*100:.2f}%)")

# ────────────────────────────────────────────────
#  Save model
# ────────────────────────────────────────────────
joblib.dump(model, "kidney_model.pkl")
print("Model saved successfully as kidney_model.pkl")

# Optional: also save the columns so brain.py knows the expected order
pd.Series(X.columns).to_csv("feature_columns.csv", index=False)
print("Feature column names saved to feature_columns.csv")