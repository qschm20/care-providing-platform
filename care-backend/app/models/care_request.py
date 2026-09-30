import enum
import uuid
from datetime import date, datetime, time, timezone

from sqlalchemy import Column, Date, DateTime, ForeignKey, Time, JSON
from sqlalchemy import Enum as SqlEnum  # ✅ Aliased to avoid collision with enum.Enum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.core.database import Base

class CareCategoryEnum(str, enum.Enum):
    senior_care = "senior_care"
    child_care = "child_care"
    pet_care = "pet_care"
    special_needs = "special_needs"

class RequestStatus(str, enum.Enum):
    pending = "pending"
    active = "active"
    cancelled = "cancelled"
    fulfilled = "fulfilled"

class CareRequest(Base):
    __tablename__ = "care_requests"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    customer_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    #  NEW: Nullable provider_id to track who accepts the request
    provider_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)

    category = Column(SqlEnum(CareCategoryEnum), nullable=False)
    requirements = Column(JSON, nullable=False)

    service_date = Column(Date, nullable=False)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)

    status = Column(SqlEnum(RequestStatus), default=RequestStatus.pending, nullable=False)

    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    customer = relationship("User", foreign_keys=[customer_id], backref="care_requests")
    provider = relationship("User", foreign_keys=[provider_id])