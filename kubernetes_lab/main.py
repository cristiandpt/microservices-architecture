import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
import joblib
from fastapi import FastAPI
from pydantic import BaseModel
import json

# 1. Load data from the JSON file
with open('purchases.json', 'r') as file:
    data = json.load(file)

df = pd.DataFrame(data)

# 2. Create the model
X = df[['hour', 'day']]
y = df['purchase']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
model = LogisticRegression()
model.fit(X_train, y_train)
joblib.dump(model, 'model.pkl')

# 3. Deploy the model
class Item(BaseModel):
    hour: int
    day: int

app = FastAPI()
model = joblib.load('model.pkl')

@app.post("/prediction/")
async def predict(item: Item):
    prediction = model.predict_proba([[item.hour, item.day]])[0][1]
    return {"purchase_probability": prediction}
