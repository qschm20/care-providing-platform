from datetime import date

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.care_request import CareRequest, RequestStatus  # ✅ Added RequestStatus
from app.models.user import User, UserRole
from app.schemas.care_request import CareRequestCreate, CareRequestResponse

router = APIRouter(prefix="/care-requests", tags=["care-requests"])


@router.post("/", response_model=CareRequestResponse, status_code=status.HTTP_201_CREATED)
def create_care_request(
    payload: CareRequestCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user.role != UserRole.customer:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only customers can create care requests."
        )
    
    if payload.end_time <= payload.start_time:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="End time must be after start time",
        )

    if payload.service_date < date.today():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Service date cannot be in the past",
        )

    if not payload.requirements:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Requirements cannot be empty",
        )

    new_request = CareRequest(
        customer_id=current_user.id,
        category=payload.category,
        requirements=payload.requirements,
        service_date=payload.service_date,
        start_time=payload.start_time,
        end_time=payload.end_time,
    )
    db.add(new_request)
    db.commit()
    db.refresh(new_request)
    return new_request


@router.get("/my", response_model=list[CareRequestResponse])
def get_my_care_requests(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return (
        db.query(CareRequest)
        .filter(CareRequest.customer_id == current_user.id)
        .order_by(CareRequest.created_at.desc())
        .all()
    )


# ✅ NEW: Customer Cancel Endpoint (Increment 7)
@router.post("/{request_id}/cancel")
def cancel_request(
    request_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # 1. Role Check
    if current_user.role != UserRole.customer:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only customers can cancel requests.")
    
    # 2. Fetch with row lock
    request = db.query(CareRequest).filter(CareRequest.id == request_id).with_for_update().first()
    
    if not request:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Request not found.")
        
    # 3. Ownership Check
    if request.customer_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You do not own this request.")
        
    # 4. State Machine Validation: Can only cancel if pending or confirmed
    if request.status not in [RequestStatus.pending, RequestStatus.confirmed]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail=f"Cannot cancel request. Current status is '{request.status.value}'. Cancellation is only allowed for 'pending' or 'confirmed' requests."
        )
        
    # 5. Update Status
    request.status = RequestStatus.cancelled
    db.commit()
    
    return {"message": "Request cancelled successfully.", "request_id": request.id}