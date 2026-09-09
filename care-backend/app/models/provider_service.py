import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, Enum, ForeignKey, Numeric, String, ARRAY
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.user import User

class PricingUnitEnum(str, enum.Enum):
    hourly = "hourly"
    daily = "daily"
    per_session = "per_session"

class ServiceCategoryEnum(str, enum.Enum):
    senior_care = "senior_care"
    child_care = "child_care"
    pet_care = "pet_care"
    special_needs = "special_needs"

class ProviderService(Base):
    __tablename__ = "provider_services"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    provider_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    # NEW FIELDS
    title = Column(String, nullable=False)
    skills = Column(ARRAY(String), nullable=True)
    hours = Column(Numeric(precision=3, scale=1), default=1.0)
    
    category = Column(Enum(ServiceCategoryEnum), nullable=False)
    description = Column(String, nullable=False)
    price = Column(Numeric(precision=10, scale=2), nullable=False) 
    pricing_unit = Column(Enum(PricingUnitEnum), nullable=False)

    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    provider = relationship("User", backref="provider_services")