import uuid
from decimal import Decimal
from typing import List, Optional

from pydantic import BaseModel

from app.models.provider_profile import VerificationStatus
from app.models.provider_service import PricingUnitEnum, ServiceCategoryEnum


class ProviderSearchServiceItem(BaseModel):
    id: uuid.UUID
    title: str
    category: ServiceCategoryEnum
    description: str
    price: Decimal
    pricing_unit: PricingUnitEnum
    skills: Optional[List[str]] = []

    class Config:
        from_attributes = True


class ProviderSearchResult(BaseModel):
    provider_id: uuid.UUID
    name: str
    bio: Optional[str] = None
    service_area: Optional[str] = None
    verification_status: VerificationStatus
    services: List[ProviderSearchServiceItem]

    class Config:
        from_attributes = True