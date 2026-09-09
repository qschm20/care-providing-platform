from fastapi import FastAPI

from fastapi.middleware.cors import CORSMiddleware #for crome

from app.core.database import Base, engine
from app.models import user  # noqa: F401
from app.models import care_request  # noqa: F401
from app.models import provider_profile  # noqa: F401
from app.models import provider_service  # noqa: F401

from app.routers import auth
from app.routers import care_requests
from app.routers import provider_services
from app.routers import provider_profiles  

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Care Providing Platform API")

#for emulating in crome
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],       # Allow Chrome to connect
    allow_credentials=True,
    allow_methods=["*"],       # Allow POST, GET, OPTIONS, etc.
    allow_headers=["*"],
)


app.include_router(auth.router)
app.include_router(care_requests.router)
app.include_router(provider_services.router)
app.include_router(provider_profiles.router)  

@app.get("/")
def root():
    return {"status": "Care Providing Platform API is running"}