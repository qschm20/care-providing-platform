from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import List, Optional

class AdminProviderServiceItem(BaseModel):
    id: UUID
    title: str
    category: str
    description: str
    price: float
    pricing_unit: str
    skills: List[str]

    class Config:
        from_attributes = True

class AdminProviderResponse(BaseModel):
    provider_id: UUID
    name: str
    email: str
    phone: Optional[str]
    bio: Optional[str]
    service_area: Optional[str]
    verification_status: str
    verification_date: Optional[datetime]
    services: List[AdminProviderServiceItem]
    average_rating: Optional[float]
    total_reviews: int

    class Config:
        from_attributes = True