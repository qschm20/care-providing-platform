import uuid
from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import BaseModel, Field

from app.models.provider_service import PricingUnitEnum, ServiceCategoryEnum


# Schema for creating a new service (what the provider sends)
class ProviderServiceCreate(BaseModel):
    category: ServiceCategoryEnum
    description: str = Field(..., min_length=10, max_length=1000)
    price: Decimal = Field(..., gt=0)  # Price must be greater than 0
    pricing_unit: PricingUnitEnum


# Schema for updating an existing service (all fields optional for partial updates)
class ProviderServiceUpdate(BaseModel):
    category: Optional[ServiceCategoryEnum] = None
    description: Optional[str] = Field(None, min_length=10, max_length=1000)
    price: Optional[Decimal] = Field(None, gt=0)
    pricing_unit: Optional[PricingUnitEnum] = None


# Schema for the response (what the API sends back to the client)
class ProviderServiceResponse(BaseModel):
    id: uuid.UUID
    provider_id: uuid.UUID
    category: ServiceCategoryEnum
    description: str
    price: Decimal
    pricing_unit: PricingUnitEnum
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True