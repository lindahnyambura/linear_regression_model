# Food Price Prediction Model

## Mission
My mission is to provide actionable insights and accurate predictions for commodity prices based on historical and contextual data. This project aims to empower decision-makers in agriculture, trade, and resource allocation with a reliable prediction system.

## Dataset Description

_The dataset was found in Kaggle and can be accessed **[here]**_

This is a price monitoring dataset for food commodities in Kenya. Here's a summary of the variable info:

**1. Geographic Information:**
- The data covers different regions (admin1) like Coast and Eastern provinces
- Specific districts/towns (admin2) like Mombasa and Kitui
- Market locations with their latitude and longitude coordinates

**2. Product Information:**
- Tracks different food categories including "cereals and tubers" and "pulses and nuts"
- Specific commodities like Maize, Beans, and Beans (dry)
- Units of measurement (KG, 90 KG)

**3. Price Information:**
- Records both wholesale and retail prices
- Prices are given in KES (Kenyan Shillings)
- Includes conversion to USD prices
- Contains price flags indicating these are "actual" prices (vs estimated or projected)

**4. Temporal Information:**
- Has date records (starting from January 15, 2006 in the shown data)

The dataset was cleaned and preprocessed to ensure accurate predictions using advanced machine learning models.

 
  ## Features

**Prediction Capabilities**
- Predict commodity prices in USD and KES.

**Analysis Tools**

- Rolling average and volatility analysis.
- Price-to-USD ratio breakdown.
- Interactive API Integration

**Easy-to-use endpoints for predictions.**
- Detailed metadata and warnings for better context.


## Key Technologies

- **Backend**: FastAPI
- **Frontend**: Flutter
- **Model Training**: Linear Regression
- **Deployment**: Render

## How To Run The Project

I made a **[demo]** you can access here

Here is a **[publicly available API endpoint]** that returns predictions given input values.


**1. Clone the Repository**
```
git clone <repository_link>
cd <project_directory>
```

**2. Install Dependencies**

- Backend:
```
pip install -r requirements.txt
```
- Frontend:
```
flutter pub get
```

**3. Run the Backend**
```
uvicorn prediction:app --reload
```

**4. Run the Frontend**
```
flutter run
```

## Challenges and Learnings
- Balancing accuracy and computational efficiency.
- Handling real-world data inconsistencies during preprocessing


[publicly available API endpoint]: <https://linear-regression-model-0kqu.onrender.com/docs>
[demo]: <https://www.loom.com/share/8cd82795fdb24aa5a7ad2779605fd5bb?sid=2345da57-9ecc-4dcf-9b6d-371e08f13762>
[here]: <https://www.kaggle.com/datasets/usmanlovescode/kenya-food-prices-dataset>
