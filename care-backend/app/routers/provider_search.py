from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import or_

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.models.provider_profile import ProviderProfile, VerificationStatus
from app.models.provider_service import ProviderService, ServiceCategoryEnum
from app.schemas.provider_search import ProviderSearchResult, ProviderSearchServiceItem

router = APIRouter(prefix="/providers", tags=["provider-search"])

@router.get("/search", response_model=List[ProviderSearchResult])
def search_providers(
    category: Optional[ServiceCategoryEnum] = Query(None, description="Filter by care category"),
    service_area: Optional[str] = Query(None, description="Filter by service area (e.g., 'Kathmandu')"),
    search: Optional[str] = Query(None, description="Search by provider name or bio"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # 1. Base query: Get all APPROVED providers (Security Rule)
    query = db.query(User, ProviderProfile).join(
        ProviderProfile, User.id == ProviderProfile.user_id
    ).filter(
        ProviderProfile.verification_status == VerificationStatus.approved
    )

    # 2. Apply text/area filters
    if service_area:
        query = query.filter(ProviderProfile.service_area.ilike(f"%{service_area}%"))

    if search:
        query = query.filter(
            or_(
                User.name.ilike(f"%{search}%"),
                ProviderProfile.bio.ilike(f"%{search}%")
            )
        )

    # 3. Apply category filter (requires checking ProviderService)
    # We find user IDs that have at least one service in this category
    if category:
        service_query = db.query(ProviderService.provider_id).filter(
            ProviderService.category == category
        )
        matched_user_ids = [row[0] for row in service_query.all()]
        
        if not matched_user_ids:
            return [] # No providers offer this category
            
        query = query.filter(User.id.in_(matched_user_ids))

    # 4. Execute query to get matching providers
    results = query.all()
    provider_dict = {}

    for user, profile in results:
        provider_dict[user.id] = ProviderSearchResult(
            provider_id=user.id,
            name=user.name,
            bio=profile.bio,
            service_area=profile.service_area,
            verification_status=profile.verification_status,
            services=[] # Populated in the next step
        )

    # 5. Fetch services for the matched providers
    if provider_dict:
        services = db.query(ProviderService).filter(
            ProviderService.provider_id.in_(list(provider_dict.keys()))
        ).all()

        for svc in services:
            if svc.provider_id in provider_dict:
                provider_dict[svc.provider_id].services.append(
                    ProviderSearchServiceItem(
                        id=svc.id,
                        title=svc.title,
                        category=svc.category,
                        description=svc.description,
                        price=svc.price,
                        pricing_unit=svc.pricing_unit,
                        skills=svc.skills or []
                    )
                )

    return list(provider_dict.values())