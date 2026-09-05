import uuid
from datetime import date, datetime, time
from typing import Any

from pydantic import BaseModel, Field

from app.models.care_request import CareCategoryEnum, RequestStatus


class CareRequestCreate(BaseModel):
    category: CareCategoryEnum
    requirements: dict[str, Any]
    service_date: date
    start_time: time
    end_time: time


class CareRequestResponse(BaseModel):
    id: uuid.UUID
    customer_id: uuid.UUID
    category: CareCategoryEnum
    requirements: dict[str, Any]
    service_date: date
    start_time: time
    end_time: time
    status: RequestStatus
    created_at: datetime

    class Config:
        from_attributes = True
