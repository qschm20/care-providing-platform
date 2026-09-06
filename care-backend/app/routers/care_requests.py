from datetime import date

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.care_request import CareRequest
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
