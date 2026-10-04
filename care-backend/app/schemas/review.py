from pydantic import BaseModel, Field
from datetime import datetime
from uuid import UUID

class ReviewCreate(BaseModel):
    care_request_id: UUID
    rating: int = Field(..., ge=1, le=5, description="Rating must be between 1 and 5")
    comment: str = Field(..., min_length=1, max_length=1000, description="Comment cannot be blank")

class ReviewResponse(BaseModel):
    id: UUID
    care_request_id: UUID
    customer_name: str
    rating: int
    comment: str
    created_at: datetime

    class Config:
        from_attributes = True

class ProviderReviewsResponse(BaseModel):
    provider_id: UUID
    average_rating: float | None
    total_reviews: int
    reviews: list[ReviewResponse]