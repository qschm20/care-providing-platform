from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import and_

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User, UserRole
from app.models.provider_profile import ProviderProfile, VerificationStatus
from app.models.provider_service import ProviderService
from app.models.care_request import CareRequest, RequestStatus

router = APIRouter(prefix="/provider/requests", tags=["provider-requests"])

def verify_approved_provider(user: User, db: Session) -> ProviderProfile:
    """Helper to ensure user is a provider and is approved"""
    if user.role != UserRole.provider:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only providers can access this resource.")
    
    profile = db.query(ProviderProfile).filter(ProviderProfile.user_id == user.id).first()
    if not profile or profile.verification_status != VerificationStatus.approved:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only approved providers can handle requests.")
    
    return profile

def check_eligibility(profile: ProviderProfile, category: str, db: Session):
    """Check if the provider actually offers a service for this category"""
    has_service = db.query(ProviderService).filter(
        and_(
            ProviderService.provider_id == profile.user_id,
            ProviderService.category == category
        )
    ).first()
    
    if not has_service:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail=f"Provider is not eligible for {category} requests."
        )

@router.get("/")
def get_matching_requests(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = verify_approved_provider(current_user, db)
    
    # Get all categories this provider offers
    provider_services = db.query(ProviderService.category).filter(
        ProviderService.provider_id == current_user.id
    ).all()
    eligible_categories = [s.category for s in provider_services]
    
    if not eligible_categories:
        return []

    # Find pending requests matching those categories
    requests = db.query(CareRequest).filter(
        and_(
            CareRequest.status == RequestStatus.pending,
            CareRequest.category.in_(eligible_categories)
        )
    ).order_by(CareRequest.created_at.desc()).all()
    
    return requests

@router.post("/{request_id}/accept")
def accept_request(
    request_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = verify_approved_provider(current_user, db)
    
    # 1. Fetch request with ROW LOCK (FOR UPDATE) to prevent race conditions
    request = db.query(CareRequest).filter(CareRequest.id == request_id).with_for_update().first()
    
    if not request:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Request not found.")
        
    # 2. Check eligibility
    check_eligibility(profile, request.category, db)
    
    # 3. First-Accept-Wins Check
    if request.status != RequestStatus.pending:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT, 
            detail=f"Request is no longer pending (current status: {request.status})."
        )
        
    # 4. Assign and update
    request.status = RequestStatus.active
    request.provider_id = current_user.id
    
    db.commit()
    return {"message": "Request accepted successfully.", "request_id": request.id}

@router.post("/{request_id}/decline")
def decline_request(
    request_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = verify_approved_provider(current_user, db)
    
    request = db.query(CareRequest).filter(CareRequest.id == request_id).first()
    
    if not request:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Request not found.")
        
    check_eligibility(profile, request.category, db)
    
    # Declining doesn't change the request status; it just removes it from this provider's view
    # (or we could log a "declined_by" relationship, but keeping it simple for Increment 6)
    
    return {"message": "Request declined."}