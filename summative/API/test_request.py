import requests
import json

url = "http://localhost:8000/predict"
payload = {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "date": "2024-01-01",
    "pricetype": "Retail",
    "currency": "KES",  # Set to KES
    "location_cluster": "urban",
    "price_to_usd_ratio": 153.50,  # Example KES/USD rate
    "rolling_avg_price": 100.0,
    "price_volatility": 0.1,
    "admin1_encoded": 1,
    "admin2_encoded": 2,
    "market_encoded": 3,
    "category_encoded": 4,
    "commodity_encoded": 5,
    "unit_encoded": 6,
    "priceflag_encoded": 7,
    "price_category_encoded": 8
}

headers = {
    'Content-Type': 'application/json'
}

response = requests.post(url, headers=headers, json=payload)
print(json.dumps(response.json(), indent=2))