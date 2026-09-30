from app.core.database import engine
from sqlalchemy import text

def run_migration():
    print("Running migration: Adding provider_id to care_requests...")
    with engine.connect() as conn:
        # Check if column already exists to prevent errors on re-runs
        result = conn.execute(text("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='care_requests' AND column_name='provider_id';
        """))
        if result.fetchone():
            print("✅ Column 'provider_id' already exists. Skipping.")
            return

        # Add the nullable column
        conn.execute(text("ALTER TABLE care_requests ADD COLUMN provider_id UUID;"))
        
        # Add the foreign key constraint
        conn.execute(text("""
            ALTER TABLE care_requests 
            ADD CONSTRAINT fk_care_requests_provider 
            FOREIGN KEY (provider_id) REFERENCES users(id) ON DELETE SET NULL;
        """))
        conn.commit()
        print("✅ Migration successful! 'provider_id' column added with foreign key constraint.")

if __name__ == "__main__":
    run_migration()