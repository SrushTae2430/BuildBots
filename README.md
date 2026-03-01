# 🩺 AyuCare – AI-Based Early Disease Detection System

AyuCare is an AI-powered early disease screening platform built during a 24-hour hackathon at TechFiesta (organized by PICT).  

It helps users assess their risk for common diseases using machine learning models and symptom-based screening.

---

## 🚀 Overview

AyuCare is available as:

- 📱 Android Application  
- 🌐 Web Application  

The system currently screens for:

- Heart Disease  
- Kidney Disease  
- Diabetes  
- Skin Disease  

It supports both chronic and non-chronic disease detection.

---

## 🎯 Problem Statement

Early detection significantly improves treatment outcomes. However:

- Many people ignore early symptoms  
- Medical tests can be expensive or inaccessible  
- Tech-heavy platforms are difficult for non-technical users  

AyuCare aims to provide a simple, accessible, AI-driven screening tool for early risk identification.

---

## ✨ Features

### 1. Simple & Accessible UI
Designed for users unfamiliar with technology.

### 2. AI-Based Risk Scoring
- Risk levels categorized as **High / Medium / Low**
- Based on parameters aligned with ICMR and IDR benchmarks
- Powered by trained ML models

### 3. Symptom-Based Screening
- Collects user-reported symptoms
- Converts qualitative inputs into numerical form
- Feeds structured data into ML models for prediction

### 4. Multiple ML Models
Four disease-specific machine learning models trained on curated datasets:
- Heart Disease
- Kidney Disease
- Diabetes
- Skin Disease

### 5. Image Recognition (Skin Disease)
Users can upload an image of a skin condition.
The system performs AI-based image classification to predict potential skin diseases.

### 6. GPS-Based Doctor Locator
- Suggests nearby doctors in high-risk cases
- Uses location services for quick assistance

### 7. Health History Tracking
- Maintains screening history
- Provides visual risk progression

### 8. PDF Report Export
Allows users to export screening results as a PDF report to share with doctors.

---

## 🛠 Tech Stack

### Frontend (Android App)
- Android Streamlit

### Web Application
- HTML
- CSS
- JavaScript

### Backend
- Python
- FastAPI 

### Machine Learning
- Scikit-learn
- Keras (for image model)
- Random forest 

### Other Integrations
- GPS Location Services
- PDF Generation Module

---

## ⚠ Disclaimer

AyuCare is a **screening tool** and not a diagnostic system.  
It does not replace professional medical advice, diagnosis, or treatment.

Users are advised to consult certified healthcare professionals for confirmed medical evaluation.

---

## 🚀 Future Improvements

- Expand to additional diseases
- Improve dataset diversity
- Deploy cloud-based model hosting
- Add multilingual support
- Integrate wearable device data

---

## 👥 Team

Tanisha Mavle 
Zahara Boharia 
Trupti Patil
Kasturi Deo
Rutuja Pardeshi





## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


