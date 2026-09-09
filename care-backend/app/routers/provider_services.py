# from decimal import Decimal
# from typing import List
# from uuid import UUID

# from fastapi import APIRouter, Depends, HTTPException, status
# from sqlalchemy.orm import Session

# from app.core.database import get_db
# from app.core.security import get_current_user
# from app.models.provider_service import ProviderService, ServiceCategoryEnum
# from app.models.user import User, UserRole
# from app.schemas.provider_service import (
#     ProviderServiceCreate,
#     ProviderServiceResponse,
#     ProviderServiceUpdate,
# )

# router = APIRouter(prefix="/provider/services", tags=["provider-services"])


# def verify_provider_role(user: User):
#     """Helper function to ensure only providers can access these endpoints"""
#     if user.role != UserRole.provider:
#         raise HTTPException(
#             status_code=status.HTTP_403_FORBIDDEN,
#             detail="Only providers can access this resource",
#         )


# @router.post("/", response_model=ProviderServiceResponse, status_code=status.HTTP_201_CREATED)
# def create_service(
#     payload: ProviderServiceCreate,
#     current_user: User = Depends(get_current_user),
#     db: Session = Depends(get_db),
# ):
#     """Create a new service for the authenticated provider"""
#     verify_provider_role(current_user)

#     # Check if provider already has a service in this category (optional business rule)
#     existing = db.query(ProviderService).filter(
#         ProviderService.provider_id == current_user.id,
#         ProviderService.category == payload.category,
#     ).first()
    
#     # Note: We're NOT preventing duplicate categories here to allow flexibility.
#     # A provider might offer "Senior Care" at different price points.

#     new_service = ProviderService(
#         provider_id=current_user.id,  # Server-side: derived from JWT, not client input
#         category=payload.category,
#         description=payload.description,
#         price=payload.price,
#         pricing_unit=payload.pricing_unit,
#     )

#     db.add(new_service)
#     db.commit()
#     db.refresh(new_service)

#     return new_service


# @router.get("/", response_model=List[ProviderServiceResponse])
# def get_my_services(
#     current_user: User = Depends(get_current_user),
#     db: Session = Depends(get_db),
# ):
#     """Get all services belonging to the authenticated provider"""
#     verify_provider_role(current_user)

#     services = (
#         db.query(ProviderService)
#         .filter(ProviderService.provider_id == current_user.id)
#         .all()
#     )

#     return services


# @router.get("/{service_id}", response_model=ProviderServiceResponse)
# def get_service(
#     service_id: UUID,
#     current_user: User = Depends(get_current_user),
#     db: Session = Depends(get_db),
# ):
#     """Get a specific service by ID (must belong to the authenticated provider)"""
#     verify_provider_role(current_user)

#     service = db.query(ProviderService).filter(
#         ProviderService.id == service_id,
#         ProviderService.provider_id == current_user.id,  # Security: ensure ownership
#     ).first()

#     if not service:
#         raise HTTPException(
#             status_code=status.HTTP_404_NOT_FOUND,
#             detail="Service not found",
#         )

#     return service


# @router.put("/{service_id}", response_model=ProviderServiceResponse)
# def update_service(
#     service_id: UUID,
#     payload: ProviderServiceUpdate,
#     current_user: User = Depends(get_current_user),
#     db: Session = Depends(get_db),
# ):
#     """Update a service (only fields provided in payload will be updated)"""
#     verify_provider_role(current_user)

#     service = db.query(ProviderService).filter(
#         ProviderService.id == service_id,
#         ProviderService.provider_id == current_user.id,  # Security: ensure ownership
#     ).first()

#     if not service:
#         raise HTTPException(
#             status_code=status.HTTP_404_NOT_FOUND,
#             detail="Service not found",
#         )

#     # Update only the fields that were provided
#     update_data = payload.model_dump(exclude_unset=True)
#     for field, value in update_data.items():
#         setattr(service, field, value)

#     db.commit()
#     db.refresh(service)

#     return service


# @router.delete("/{service_id}", status_code=status.HTTP_204_NO_CONTENT)
# def delete_service(
#     service_id: UUID,
#     current_user: User = Depends(get_current_user),
#     db: Session = Depends(get_db),
# ):
#     """Delete a service (must belong to the authenticated provider)"""
#     verify_provider_role(current_user)

#     service = db.query(ProviderService).filter(
#         ProviderService.id == service_id,
#         ProviderService.provider_id == current_user.id,  # Security: ensure ownership
#     ).first()

#     if not service:
#         raise HTTPException(
#             status_code=status.HTTP_404_NOT_FOUND,
#             detail="Service not found",
#         )

#     db.delete(service)
#     db.commit()

#     return None


from decimal import Decimal
from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.provider_service import ProviderService, ServiceCategoryEnum
from app.models.user import User, UserRole
from app.schemas.provider_service import (
    ProviderServiceCreate,
    ProviderServiceResponse,
    ProviderServiceUpdate,
)

router = APIRouter(prefix="/provider/services", tags=["provider-services"])


def verify_provider_role(user: User):
    """Helper function to ensure only providers can access these endpoints"""
    if user.role != UserRole.provider:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only providers can access this resource",
        )


@router.post("/", response_model=ProviderServiceResponse, status_code=status.HTTP_201_CREATED)
def create_service(
    payload: ProviderServiceCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create a new service for the authenticated provider"""
    verify_provider_role(current_user)

    # --- FIXED: Now includes all new fields ---
    new_service = ProviderService(
        provider_id=current_user.id,
        title=payload.title,           # ✅ Added
        category=payload.category,
        description=payload.description,
        price=payload.price,
        pricing_unit=payload.pricing_unit,
        hours=payload.hours,           # ✅ Added
        skills=payload.skills,         # ✅ Added
    )
    # -----------------------------------------

    db.add(new_service)
    db.commit()
    db.refresh(new_service)

    return new_service


@router.get("/", response_model=List[ProviderServiceResponse])
def get_my_services(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get all services belonging to the authenticated provider"""
    verify_provider_role(current_user)

    services = (
        db.query(ProviderService)
        .filter(ProviderService.provider_id == current_user.id)
        .all()
    )

    return services


@router.get("/{service_id}", response_model=ProviderServiceResponse)
def get_service(
    service_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get a specific service by ID (must belong to the authenticated provider)"""
    verify_provider_role(current_user)

    service = db.query(ProviderService).filter(
        ProviderService.id == service_id,
        ProviderService.provider_id == current_user.id,
    ).first()

    if not service:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service not found",
        )

    return service


@router.put("/{service_id}", response_model=ProviderServiceResponse)
def update_service(
    service_id: UUID,
    payload: ProviderServiceUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update a service (only fields provided in payload will be updated)"""
    verify_provider_role(current_user)

    service = db.query(ProviderService).filter(
        ProviderService.id == service_id,
        ProviderService.provider_id == current_user.id,
    ).first()

    if not service:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service not found",
        )

    update_data = payload.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(service, field, value)

    db.commit()
    db.refresh(service)

    return service


@router.delete("/{service_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_service(
    service_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Delete a service (must belong to the authenticated provider)"""
    verify_provider_role(current_user)

    service = db.query(ProviderService).filter(
        ProviderService.id == service_id,
        ProviderService.provider_id == current_user.id,
    ).first()

    if not service:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service not found",
        )

    db.delete(service)
    db.commit()

    return None