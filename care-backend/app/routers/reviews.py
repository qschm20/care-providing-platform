from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User, UserRole
from app.models.care_request import CareRequest, RequestStatus
from app.models.review import Review
from app.schemas.review import ReviewCreate, ReviewResponse, ProviderReviewsResponse

router = APIRouter(prefix="/reviews", tags=["reviews"])

@router.post("/", response_model=ReviewResponse, status_code=status.HTTP_201_CREATED)
def submit_review(
    payload: ReviewCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # 1. Role Check
    if current_user.role != UserRole.customer:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only customers can submit reviews.")

    # 2. Fetch the care request
    request = db.query(CareRequest).filter(CareRequest.id == payload.care_request_id).first()
    if not request:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Care request not found.")

    # 3. Ownership Check
    if request.customer_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="You can only review your own care requests.")

    # 4. Status Check
    if request.status != RequestStatus.completed:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail=f"Cannot review request. Status must be 'completed', currently '{request.status.value}'."
        )

    # 5. Provider Check
    if not request.provider_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="This request has no assigned provider.")

    # 6. Duplicate Check
    existing_review = db.query(Review).filter(Review.care_request_id == payload.care_request_id).first()
    if existing_review:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="You have already reviewed this care request.")

    # 7. Create Review
    new_review = Review(
        care_request_id=payload.care_request_id,
        customer_id=current_user.id,
        provider_id=request.provider_id,
        rating=payload.rating,
        comment=payload.comment.strip()
    )
    
    db.add(new_review)
    db.commit()
    db.refresh(new_review)

    # Return response with customer name
    return ReviewResponse(
        id=new_review.id,
        care_request_id=new_review.care_request_id,
        customer_name=current_user.name,
        rating=new_review.rating,
        comment=new_review.comment,
        created_at=new_review.created_at
    )

@router.get("/provider/{provider_id}", response_model=ProviderReviewsResponse)
def get_provider_reviews(
    provider_id: str,
    db: Session = Depends(get_db)
):
    # Calculate average and count dynamically
    stats = db.query(
        func.avg(Review.rating).label('avg_rating'),
        func.count(Review.id).label('total')
    ).filter(Review.provider_id == provider_id).first()

    avg_rating = round(float(stats.avg_rating), 1) if stats.avg_rating else None
    total_reviews = stats.total or 0

    # Fetch individual reviews with customer names
    reviews = db.query(Review, User.name).join(
        User, Review.customer_id == User.id
    ).filter(
        Review.provider_id == provider_id
    ).order_by(Review.created_at.desc()).all()

    review_list = [
        ReviewResponse(
            id=rev.id,
            care_request_id=rev.care_request_id,
            customer_name=name,
            rating=rev.rating,
            comment=rev.comment,
            created_at=rev.created_at
        )
        for rev, name in reviews
    ]

    return ProviderReviewsResponse(
        provider_id=provider_id,
        average_rating=avg_rating,
        total_reviews=total_reviews,
        reviews=review_list
    )

@router.get("/care-request/{care_request_id}")
def check_request_review(
    care_request_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Check if a review exists for this request
    review = db.query(Review).filter(Review.care_request_id == care_request_id).first()
    
    if review:
        return {"has_review": True, "review_id": str(review.id)}
    return {"has_review": False}