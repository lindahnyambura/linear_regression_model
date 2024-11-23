from fastapi import FastAPI
from pydantic import BaseModel, Field
import joblib
import numpy as np
from sklearn.preprocessing import StandardScaler
from fastapi.middleware.cors import CORSMiddleware

# Load the trained model 
model = joblib.load('random_forest_model.joblib')

# Initialize FastAPI app
app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "hi!"}

# Add CORS middleware to allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods (GET, POST, etc.)
    allow_headers=["*"],  # Allows all headers
)

# Define the input data model using Pydantic
class PredictionRequest(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)  # Latitude range from -90 to 90
    longitude: float = Field(..., ge=-180, le=180)  # Longitude range from -180 to 180
    month: int = Field(..., ge=1, le=12)  # Month range from 1 to 12
    day_of_week: int = Field(..., ge=0, le=6)  # Day of the week (0 to 6)
    price_to_usd_ratio: float = Field(..., ge=0)  # Price to USD ratio should be non-negative
    rolling_avg_price: float = Field(..., ge=0)  # Rolling average price should be non-negative
    price_volatility: float = Field(..., ge=0)  # Price volatility should be non-negative
    admin1_encoded: int
    admin2_encoded: int
    market_encoded: int
    category_encoded: int
    commodity_encoded: int
    unit_encoded: int
    priceflag_encoded: int
    price_category_encoded: int

# Define the prediction endpoint
@app.post('/predict')
def predict(data: PredictionRequest):
    # Convert input data into a numpy array
    input_data = np.array([[data.latitude, data.longitude, data.month, data.day_of_week,
                            data.price_to_usd_ratio, data.rolling_avg_price, data.price_volatility,
                            data.admin1_encoded, data.admin2_encoded, data.market_encoded,
                            data.category_encoded, data.commodity_encoded, data.unit_encoded,
                            data.priceflag_encoded, data.price_category_encoded]])

    # Scale the input data (assuming the model was trained with scaled data)
    scaler = StandardScaler()
    input_data_scaled = scaler.fit_transform(input_data)  # Use the same scaler as used for training

    # Make the prediction
    prediction = model.predict(input_data_scaled)

    # Return the prediction result
    return {"prediction": prediction[0]}

# For running the app using uvicorn, include the following
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
