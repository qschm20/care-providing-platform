import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, DateTime, Enum, ForeignKey, String, Time, Date
from sqlalchemy.dialects.postgresql import UUID, JSONB
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

    category = Column(Enum(CareCategoryEnum), nullable=False)
    requirements = Column(JSONB, nullable=False)

    service_date = Column(Date, nullable=False)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)

    status = Column(Enum(RequestStatus), default=RequestStatus.pending, nullable=False)

    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    customer = relationship("User", backref="care_requests")