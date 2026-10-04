from app.core.database import engine, Base

from app.models.user import User
from app.models.care_request import CareRequest
from app.models.review import Review 

def run_migration():
    print("Running migration: Creating 'reviews' table...")
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Migration successful! 'reviews' table is ready.")
    except Exception as e:
        print(f"❌ Migration failed: {e}")

if __name__ == "__main__":
    run_migration()