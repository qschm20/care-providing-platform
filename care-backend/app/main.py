from fastapi import FastAPI

from app.core.database import Base, engine
from app.models import user  # noqa: F401 -- ensures model is registered before create_all
from app.routers import auth
from app.models import care_request  # noqa: F401
from app.routers import care_requests

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Care Providing Platform API")

app.include_router(auth.router)
app.include_router(care_requests.router)

@app.get("/")
def root():
    return {"status": "Care Providing Platform API is running"}