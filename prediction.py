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

# Load the pre-trained Random Forest model
current_dir = os.path.dirname(__file__)
model_path = os.path.join(current_dir, "random_forest_model.joblib")
model = joblib.load(model_path)

app = FastAPI(
    title="Price Prediction API",
    description="API for predicting commodity prices in KES and USD",
    version="1.0.0"
)

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

    @field_validator('rolling_avg_price')
    def validate_rolling_avg(cls, v):
        if v < 0:
            raise ValueError('Rolling average price cannot be negative')
        return v

    @field_validator('price_volatility')
    def validate_volatility(cls, v):
        if v < 0:
            raise ValueError('Price volatility cannot be negative')
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

        #load the scaler
        scaler_path = os.path.join(current_dir, "scaler.pkl")
        if not os.path.exists(scaler_path):
            raise FileNotFoundError("Scaler file not found")

        scaler = joblib.load(scaler_path)

        #scale the input features
        scaled_features = scaler.transform([input_features])
        return scaled_features
    except Exception as e:
        raise HTTPException(
            status_code=400,
            detail={"message": "Preprocessing error", "error": str(e)}
        )

def post_process_prediction(predicted_price: float, confidence_interval: dict = None) -> tuple:
    """
    Post-process the prediction to ensure non-negative prices and adjust confidence intervals
    """
    # Apply a minimum threshold (e.g., 0.01) for prices
    processed_price = max(0.01, predicted_price)
    
    if confidence_interval:
        processed_ci = {
            "lower_bound": max(0.01, confidence_interval["lower_bound"]),
            "upper_bound": max(0.01, confidence_interval["upper_bound"])
        }
        # Ensure lower bound doesn't exceed upper bound
        if processed_ci["lower_bound"] > processed_ci["upper_bound"]:
            processed_ci["lower_bound"] = processed_ci["upper_bound"]
    else:
        processed_ci = None
        
    return processed_price, processed_ci

@app.post('/predict', response_model=dict)
async def predict(data: PredictionRequest):
    try:
        preprocessed_data = preprocess_input(data)
        predicted_price_usd = float(model.predict(preprocessed_data)[0])
        
        # Calculate confidence intervals
        if hasattr(model, 'estimators_'):
            tree_predictions = [tree.predict(preprocessed_data)[0] for tree in model.estimators_]
            confidence_interval_usd = {
                "lower_bound": float(np.percentile(tree_predictions, 25)),
                "upper_bound": float(np.percentile(tree_predictions, 75))
            }
        else:
            confidence_interval_usd = None

        # Post-process USD predictions
        processed_price_usd, processed_ci_usd = post_process_prediction(
            predicted_price_usd, 
            confidence_interval_usd
        )
        
        # Convert to KES and post-process
        predicted_price_kes = processed_price_usd * data.price_to_usd_ratio
        confidence_interval_kes = None
        if processed_ci_usd:
            confidence_interval_kes = {
                "lower_bound": processed_ci_usd["lower_bound"] * data.price_to_usd_ratio,
                "upper_bound": processed_ci_usd["upper_bound"] * data.price_to_usd_ratio
            }

        # Add warning if original prediction was negative
        warnings = []
        if predicted_price_usd < 0:
            warnings.append("Original prediction was negative and was adjusted to ensure non-negative prices")

        return {
            "status": "success",
            "predictions": {
                "usd": {
                    "price": round(processed_price_usd, 2),
                    "confidence_interval": processed_ci_usd
                },
                "kes": {
                    "price": round(predicted_price_kes, 2),
                    "confidence_interval": confidence_interval_kes
                }
            },
            "analysis": {
                "current_rolling_average": float(data.rolling_avg_price),
                "price_volatility": float(data.price_volatility),
                "price_to_usd_ratio": float(data.price_to_usd_ratio)
            },
            "metadata": {
                "prediction_date": data.date,
                "location": {
                    "latitude": data.latitude,
                    "longitude": data.longitude,
                    "cluster": data.location_cluster
                },
                "price_type": data.pricetype
            },
            "warnings": warnings if warnings else None
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