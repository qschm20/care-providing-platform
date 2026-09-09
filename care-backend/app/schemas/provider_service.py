import uuid
from datetime import datetime
from decimal import Decimal
from typing import Optional, List

from pydantic import BaseModel, Field

from app.models.provider_service import PricingUnitEnum, ServiceCategoryEnum

class ProviderServiceCreate(BaseModel):
    title: str = Field(..., min_length=3, max_length=100)
    category: ServiceCategoryEnum
    description: str = Field(..., min_length=10, max_length=1000)
    price: Decimal = Field(..., gt=0)
    pricing_unit: PricingUnitEnum
    hours: Decimal = Field(default=1.0, gt=0)
    skills: Optional[List[str]] = []

class ProviderServiceUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=3, max_length=100)
    category: Optional[ServiceCategoryEnum] = None
    description: Optional[str] = Field(None, min_length=10, max_length=1000)
    price: Optional[Decimal] = Field(None, gt=0)
    pricing_unit: Optional[PricingUnitEnum] = None
    hours: Optional[Decimal] = Field(None, gt=0)
    skills: Optional[List[str]] = None

class ProviderServiceResponse(BaseModel):
    id: uuid.UUID
    provider_id: uuid.UUID
    title: Optional[str] = None
    category: ServiceCategoryEnum
    description: str
    price: Decimal
    pricing_unit: PricingUnitEnum
    hours: Decimal                      
    skills: Optional[List[str]] = []
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True