from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import create_access_token, get_current_user, hash_password, verify_password
from app.models.user import User
from app.schemas.user import UserLogin, UserRegister, UserResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(payload: UserRegister, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == payload.email).first()
    if existing_user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

    new_user = User(
        name=payload.name,
        email=payload.email,
        phone=payload.phone,
        password_hash=hash_password(payload.password),
        role=payload.role,
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user


@router.post("/login")
def login(payload: UserLogin, db: Session = Depends(get_db)):
    print(f"\n--- LOGIN ATTEMPT START ---")
    print(f"Received Email: '{payload.email}'")
    
    user = db.query(User).filter(User.email == payload.email).first()

    if not user:
        print("DEBUG: No user found with this email in the database.")
    else:
        print(f"DEBUG: User found! ID: {user.id}")
        is_valid = verify_password(payload.password, user.password_hash)
        print(f"DEBUG: Password matches? {is_valid}")

    if not user or not verify_password(payload.password, user.password_hash):
        print("--- LOGIN FAILED ---\n")
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")

    print("--- LOGIN SUCCESS ---\n")
    access_token = create_access_token(data={"sub": str(user.id), "role": user.role.value})

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": UserResponse.model_validate(user),
    }


@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user