import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel

from app.models.provider_profile import VerificationStatus


class ProviderProfileCreate(BaseModel):
    bio: Optional[str] = None
    service_area: Optional[str] = None


class ProviderProfileResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    bio: Optional[str] = None
    service_area: Optional[str] = None
    verification_status: VerificationStatus
    verification_date: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True