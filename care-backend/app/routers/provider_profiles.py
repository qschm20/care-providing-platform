from datetime import datetime, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.provider_profile import ProviderProfile, VerificationStatus
from app.models.user import User, UserRole
from app.schemas.provider_profile import ProviderProfileCreate, ProviderProfileResponse

router = APIRouter(prefix="/provider/profile", tags=["provider-profile"])


def verify_provider_role(user: User):
    """Helper function to ensure only providers can access these endpoints"""
    if user.role != UserRole.provider:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only providers can access this resource",
        )


@router.get("/", response_model=ProviderProfileResponse)
def get_or_create_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get the authenticated provider's profile, or create a default one if it doesn't exist"""
    verify_provider_role(current_user)

    profile = db.query(ProviderProfile).filter(ProviderProfile.user_id == current_user.id).first()

    if not profile:
        # Auto-create a blank profile if the provider hasn't set one up yet
        profile = ProviderProfile(
            user_id=current_user.id,
            verification_status=VerificationStatus.pending
        )
        db.add(profile)
        db.commit()
        db.refresh(profile)

    return profile


@router.put("/", response_model=ProviderProfileResponse)
def update_profile(
    payload: ProviderProfileCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update the authenticated provider's bio and service area"""
    verify_provider_role(current_user)

    profile = db.query(ProviderProfile).filter(ProviderProfile.user_id == current_user.id).first()

    if not profile:
        # Create if it doesn't exist
        profile = ProviderProfile(
            user_id=current_user.id,
            bio=payload.bio,
            service_area=payload.service_area,
            verification_status=VerificationStatus.pending
        )
        db.add(profile)
    else:
        # Update existing
        if payload.bio is not None:
            profile.bio = payload.bio
        if payload.service_area is not None:
            profile.service_area = payload.service_area

    db.commit()
    db.refresh(profile)

    return profile


@router.post("/submit-verification", response_model=ProviderProfileResponse)
def submit_for_verification(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Provider submits their profile for admin verification"""
    verify_provider_role(current_user)

    profile = db.query(ProviderProfile).filter(ProviderProfile.user_id == current_user.id).first()

    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found. Please create a profile first."
        )

    if profile.verification_status == VerificationStatus.approved:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Profile is already verified."
        )

    # Reset to pending and clear previous verification date if rejected
    profile.verification_status = VerificationStatus.pending
    profile.verification_date = None
    
    db.commit()
    db.refresh(profile)

    return profile