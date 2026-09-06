import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, Enum, ForeignKey, Numeric, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.user import User # Import User to establish the relationship

# Enum for the pricing unit (kept simple for this academic project)
class PricingUnitEnum(str, enum.Enum):
    hourly = "hourly"
    daily = "daily"
    per_session = "per_session"

# Enum for care categories (must match the customer side exactly)
class ServiceCategoryEnum(str, enum.Enum):
    senior_care = "senior_care"
    child_care = "child_care"
    pet_care = "pet_care"
    special_needs = "special_needs"


class ProviderService(Base):
    __tablename__ = "provider_services"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Link to the User table. We use the user's ID as the provider ID.
    provider_id = Column(
        UUID(as_uuid=True), 
        ForeignKey("users.id", ondelete="CASCADE"), 
        nullable=False
    )
    
    category = Column(Enum(ServiceCategoryEnum), nullable=False)
    description = Column(String, nullable=False)
    
    # Using Numeric for price to avoid floating-point rounding errors (best practice)
    price = Column(Numeric(precision=10, scale=2), nullable=False) 
    pricing_unit = Column(Enum(PricingUnitEnum), nullable=False)

    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    # Relationship: Allows us to do user.provider_services in the future
    provider = relationship("User", backref="provider_services")