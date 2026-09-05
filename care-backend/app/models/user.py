import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import Column, String, Enum, DateTime
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base


class UserRole(str, enum.Enum):
    customer = "customer"
    provider = "provider"
    admin = "admin"


class UserStatus(str, enum.Enum):
    active = "active"
    suspended = "suspended"


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False, index=True)
    phone = Column(String, nullable=True)
    password_hash = Column(String, nullable=False)
    # role = Column(Enum(UserRole), nullable=False)
    role = Column(Enum(UserRole), nullable=False, default=UserRole.customer)
    profile_image = Column(String, nullable=True)
    emergency_contact = Column(String, nullable=True)
    status = Column(Enum(UserStatus), nullable=False, default=UserStatus.active)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )