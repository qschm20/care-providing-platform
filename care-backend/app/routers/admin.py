from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timezone

from app.core.database import get_db
from app.core.security import get_current_admin
from app.models.user import User, UserRole
from app.models.provider_profile import ProviderProfile, VerificationStatus
from app.models.provider_service import ProviderService
from app.models.review import Review
from app.schemas.admin import AdminProviderResponse, AdminProviderServiceItem

router = APIRouter(prefix="/admin", tags=["admin"])

# Helper function to avoid code duplication
def _get_provider_details(db: Session, user_id: str):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return None
    profile = db.query(ProviderProfile).filter(ProviderProfile.user_id == user_id).first()
    services = db.query(ProviderService).filter(ProviderService.provider_id == user_id).all()
    stats = db.query(
        func.avg(Review.rating).label('avg_rating'),
        func.count(Review.id).label('total')
    ).filter(Review.provider_id == user_id).first()
    
    return AdminProviderResponse(
        provider_id=user.id,
        name=user.name,
        email=user.email,
        phone=user.phone,
        bio=profile.bio if profile else None,
        service_area=profile.service_area if profile else None,
        verification_status=profile.verification_status.value if profile else "unknown",
        verification_date=profile.verification_date if profile else None,
        services=[
            AdminProviderServiceItem(
                id=svc.id, title=svc.title, category=svc.category.value,
                description=svc.description, price=svc.price, pricing_unit=svc.pricing_unit, skills=svc.skills or []
            ) for svc in services
        ],
        average_rating=round(float(stats.avg_rating), 1) if stats.avg_rating else None,
        total_reviews=stats.total or 0
    )

@router.get("/providers", response_model=list[AdminProviderResponse])
def get_providers(
    status_filter: str | None = None,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    query = db.query(User, ProviderProfile).join(
        ProviderProfile, User.id == ProviderProfile.user_id
    ).filter(User.role == UserRole.provider)

    if status_filter:
        try:
            status_enum = VerificationStatus(status_filter.lower())
            query = query.filter(ProviderProfile.verification_status == status_enum)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid status filter")

    results = query.all()
    return [_get_provider_details(db, user.id) for user, profile in results if _get_provider_details(db, user.id)]

@router.post("/providers/{provider_id}/approve", response_model=AdminProviderResponse)
def approve_provider(
    provider_id: str,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    profile = db.query(ProviderProfile).filter(ProviderProfile.user_id == provider_id).first()
    if not profile:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found")
    
    profile.verification_status = VerificationStatus.approved
    profile.verification_date = datetime.now(timezone.utc)
    db.commit()
    
    updated_provider = _get_provider_details(db, provider_id)
    if not updated_provider:
        raise HTTPException(status_code=404, detail="Provider not found after update")
    return updated_provider

@router.post("/providers/{provider_id}/reject", response_model=AdminProviderResponse)
def reject_provider(
    provider_id: str,
    current_user: User = Depends(get_current_admin),
    db: Session = Depends(get_db)
):
    profile = db.query(ProviderProfile).filter(ProviderProfile.user_id == provider_id).first()
    if not profile:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider profile not found")
    
    profile.verification_status = VerificationStatus.rejected
    profile.verification_date = datetime.now(timezone.utc)
    db.commit()
    
    updated_provider = _get_provider_details(db, provider_id)
    if not updated_provider:
        raise HTTPException(status_code=404, detail="Provider not found after update")
    return updated_provider