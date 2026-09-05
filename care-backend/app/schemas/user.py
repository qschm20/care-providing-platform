import uuid
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr

from app.models.user import UserRole, UserStatus


class UserRegister(BaseModel):
    name: str
    email: EmailStr
    phone: Optional[str] = None
    password: str
    role: UserRole


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: uuid.UUID
    name: str
    email: EmailStr
    phone: Optional[str] = None
    role: UserRole
    profile_image: Optional[str] = None
    status: UserStatus
    created_at: datetime

    class Config:
        from_attributes = True