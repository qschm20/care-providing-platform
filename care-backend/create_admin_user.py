import os
import sys
from sqlalchemy.orm import Session

# Ensure we can import from the app directory
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import SessionLocal
from app.models.user import User, UserRole, UserStatus
from app.core.security import hash_password

def create_admin_user():
    db: Session = SessionLocal()
    try:
        admin_email = "admin@care.app"
        admin_password = "admin123"
        
        # 1. Check if admin already exists (Idempotent check)
        existing_admin = db.query(User).filter(User.email == admin_email).first()
        
        if existing_admin:
            print(f"✅ Admin user '{admin_email}' already exists. No changes made.")
            return

        # 2. Create new admin user
        new_admin = User(
            name="System Administrator",
            email=admin_email,
            phone="9800000000",
            password_hash=hash_password(admin_password),
            role=UserRole.admin,
            status=UserStatus.active
        )
        
        db.add(new_admin)
        db.commit()
        print("✅ SUCCESS: Admin user created successfully!")
        print(f"   👤 Email:    {admin_email}")
        print(f"   🔑 Password: {admin_password}")
        print("   ⚠️ Note: This is a development account. Do not use in production.")
        
    except Exception as e:
        db.rollback()
        print(f"❌ FAILED: Could not create admin user. Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    create_admin_user()