from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, field_validator
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
import joblib
import numpy as np
import math
import os
from typing import List

# Load the pre-trained Linear Regression model
current_dir = os.path.dirname(__file__)
model_path = os.path.join(current_dir, "linear_regression_model.joblib")
model = joblib.load(model_path)

app = FastAPI(
    title="Price Prediction API",
    description="API for predicting commodity prices in KES and USD",
    version="1.0.0"
)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Price Prediction API!"}
    
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PredictionRequest(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    date: str = Field(..., description="Date in YYYY-MM-DD format")
    pricetype: str = Field(..., description="Type of price (e.g., 'Retail', 'Wholesale')")
    currency: str = Field(..., description="Currency code (KES or USD)")
    location_cluster: str
    price_to_usd_ratio: float = Field(..., ge=0, description="KES to USD ratio")
    rolling_avg_price: float = Field(..., ge=0)
    price_volatility: float = Field(..., ge=0)
    admin1_encoded: int
    admin2_encoded: int
    market_encoded: int
    category_encoded: int
    commodity_encoded: int
    unit_encoded: int
    priceflag_encoded: int
    price_category_encoded: int

    @field_validator('currency')
    def validate_currency(cls, v):
        if v not in ['KES', 'USD']:
            raise ValueError('Currency must be either KES or USD')
        return v

def preprocess_input(data: PredictionRequest):
    try:
        date_obj = datetime.strptime(data.date, "%Y-%m-%d")
        year = date_obj.year
        month = date_obj.month
        day_of_week = date_obj.weekday()
        day_of_year = date_obj.timetuple().tm_yday
        month_sin = math.sin(2 * math.pi * month / 12)
        month_cos = math.cos(2 * math.pi * month / 12)
        
        input_features = [
            data.latitude,
            data.longitude,
            year,
            month,
            day_of_week,
            day_of_year,
            month_sin,
            month_cos,
            data.price_to_usd_ratio,
            data.rolling_avg_price,
            data.price_volatility,
            data.admin1_encoded,
            data.admin2_encoded,
            data.market_encoded,
            data.category_encoded,
            data.commodity_encoded,
            data.unit_encoded,
            data.priceflag_encoded,
            data.price_category_encoded,
            int(data.pricetype == "Retail"),
            int(data.currency == "USD")
        ]

        scaler_path = os.path.join(current_dir, "scaler.pkl")
        if not os.path.exists(scaler_path):
            raise FileNotFoundError("Scaler file not found")

        scaler = joblib.load(scaler_path)
        scaled_features = scaler.transform([input_features])
        return scaled_features

    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail={"message": "Preprocessing error", "error": str(e)}
        )

def process_prediction(predicted_price: float) -> float:
    """
    Process the prediction to ensure reasonable price values
    """
    # Set minimum threshold for prices
    MIN_PRICE = 0.01
    # Set maximum threshold for prices
    MAX_PRICE_USD = 500.0 
    
    # Clip prediction between min and max values
    processed_price = np.clip(predicted_price, MIN_PRICE, MAX_PRICE_USD)
    
    return float(processed_price)

@app.post('/predict', response_model=dict)
async def predict(data: PredictionRequest):
    try:
        preprocessed_data = preprocess_input(data)
        predicted_price_usd = float(model.predict(preprocessed_data)[0])
        
        # Process USD prediction
        processed_price_usd = process_prediction(predicted_price_usd)
        
        # Convert to KES
        predicted_price_kes = processed_price_usd * data.price_to_usd_ratio

        # Calculate percentage difference from rolling average
        price_diff_percent = ((processed_price_usd - data.rolling_avg_price) / 
                            data.rolling_avg_price * 100 if data.rolling_avg_price > 0 else 0)

        # Add price trend analysis
        price_trend = "stable"
        if abs(price_diff_percent) > 20:  # Threshold for significant change
            price_trend = "increasing" if price_diff_percent > 0 else "decreasing"

        return {
            "status": "success",
            "predictions": {
                "usd": {
                    "price": round(processed_price_usd, 2)
                },
                "kes": {
                    "price": round(predicted_price_kes, 2)
                }
            },
            "analysis": {
                "current_rolling_average": float(data.rolling_avg_price),
                "price_volatility": float(data.price_volatility),
                "price_to_usd_ratio": float(data.price_to_usd_ratio),
                "price_trend": price_trend,
                "price_difference_percent": round(price_diff_percent, 2)
            },
            "metadata": {
                "prediction_date": data.date,
                "location": {
                    "latitude": data.latitude,
                    "longitude": data.longitude,
                    "cluster": data.location_cluster
                },
                "price_type": data.pricetype
            }
        }
    
    except ValueError as ve:
        raise HTTPException(
            status_code=500,
            detail={"message": "Prediction failed", "error": str(ve)}
        )
    except Exception as e:
        raise HTTPException(
            status_code=500, 
            detail={"message": "Unexpected error", "error": str(e)}
        )
