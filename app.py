from fastapi import FastAPI
from pydantic import BaseModel
import redis

app = FastAPI()

class Item(BaseModel):
    key: str
    value: str

## Redis Connection
r = redis.Redis(host='redis', port=6379, db=0, decode_responses=True)

@app.get("/")
async def root():
    return {"owner": "Cristian David Pacheco"}

@app.post("/add/")
async def add_item(item: Item):
    r.set(item.key, item.value)
    return {"status": "Item added successfully"}

@app.get("/get/{key}/")
async def get_item(key: str):
    value = r.get(key)
    if value is None:
        return {"Error": "Key not found"}
    else:
        return {"key": key, "value": value}
