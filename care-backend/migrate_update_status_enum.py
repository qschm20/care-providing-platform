from app.core.database import engine
from sqlalchemy import text

def run_migration():
    print("Running migration: Updating RequestStatus enum...")
    with engine.connect() as conn:
        # 1. Add new enum values to the PostgreSQL type
        # Note: 'confirmed' and 'completed' might already exist if you ran partial tests, 
        # but 'in_progress' is definitely new.
        conn.execute(text("ALTER TYPE requeststatus ADD VALUE IF NOT EXISTS 'confirmed';"))
        conn.execute(text("ALTER TYPE requeststatus ADD VALUE IF NOT EXISTS 'in_progress';"))
        conn.execute(text("ALTER TYPE requeststatus ADD VALUE IF NOT EXISTS 'completed';"))
        conn.commit()
        
        # 2. Map old values to new values to preserve existing data
        # 'active' -> 'confirmed'
        conn.execute(text("UPDATE care_requests SET status = 'confirmed' WHERE status = 'active';"))
        # 'fulfilled' -> 'completed'
        conn.execute(text("UPDATE care_requests SET status = 'completed' WHERE status = 'fulfilled';"))
        conn.commit()
        
        print("✅ Migration successful! Status enum updated and data mapped.")

if __name__ == "__main__":
    run_migration()