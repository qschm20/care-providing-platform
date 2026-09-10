from app.core.database import SessionLocal
from app.models.provider_profile import ProviderProfile, VerificationStatus
from app.models.user import User

db = SessionLocal()
try:
    # Update all pending profiles to approved just for testing
    db.query(ProviderProfile).update({ProviderProfile.verification_status: VerificationStatus.approved})
    db.commit()
    print("All providers are now approved! Refresh your Flutter app.")
finally:
    db.close()
