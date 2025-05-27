from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from .. import models, schemas
from ..database import get_db
from passlib.context import CryptContext
from pydantic import BaseModel

router = APIRouter(prefix="/personas", tags=["personas"])

# Configuración para el hashing de contraseñas
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

class PasswordReset(BaseModel):
    numero_identificacion: str
    new_password: str

@router.post("/", response_model=schemas.Persona)
def create_persona(persona: schemas.PersonaCreate, db: Session = Depends(get_db)):
    # Verificar si el correo ya está registrado
    db_persona = db.query(models.Persona).filter(
        models.Persona.correo == persona.correo
    ).first()
    if db_persona:
        raise HTTPException(status_code=400, detail="Correo ya registrado")
    
    # Verificar si el número de identificación ya existe
    db_persona = db.query(models.Persona).filter(
        models.Persona.numero_identificacion == persona.numero_identificacion
    ).first()
    if db_persona:
        raise HTTPException(status_code=400, detail="Número de identificación ya registrado")
    
    # Hash de la contraseña
    hashed_password = get_password_hash(persona.password)
    
    db_persona = models.Persona(
        **persona.model_dump(exclude={"password"}),
        hashed_password=hashed_password
    )
    
    db.add(db_persona)
    db.commit()
    db.refresh(db_persona)
    return db_persona

@router.get("/", response_model=list[schemas.Persona])
def read_personas(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    personas = db.query(models.Persona).offset(skip).limit(limit).all()
    return personas

@router.get("/{persona_id}", response_model=schemas.Persona)
def read_persona(persona_id: int, db: Session = Depends(get_db)):
    db_persona = db.query(models.Persona).filter(
        models.Persona.id_persona == persona_id
    ).first()
    if db_persona is None:
        raise HTTPException(status_code=404, detail="Persona no encontrada")
    return db_persona

@router.put("/{persona_id}", response_model=schemas.Persona)
def update_persona(
    persona_id: int, 
    persona: schemas.PersonaCreate, 
    db: Session = Depends(get_db)
):
    db_persona = db.query(models.Persona).filter(
        models.Persona.id_persona == persona_id
    ).first()
    if db_persona is None:
        raise HTTPException(status_code=404, detail="Persona no encontrada")
    
    # Actualizar campos (sin contraseña)
    for field, value in persona.model_dump(exclude={"password", "current_password", "new_password"}).items():
        setattr(db_persona, field, value)
    
    # Manejar cambio de contraseña: requiere current_password y new_password
    if persona.new_password:
        # Verificar contraseña actual
        if not persona.current_password or not verify_password(persona.current_password, db_persona.hashed_password):
            raise HTTPException(status_code=400, detail="Contraseña actual incorrecta")
        db_persona.hashed_password = get_password_hash(persona.new_password)
    
    db.commit()
    db.refresh(db_persona)
    return db_persona

@router.delete("/{persona_id}")
def delete_persona(persona_id: int, db: Session = Depends(get_db)):
    db_persona = db.query(models.Persona).filter(
        models.Persona.id_persona == persona_id
    ).first()
    if db_persona is None:
        raise HTTPException(status_code=404, detail="Persona no encontrada")
    
    db.delete(db_persona)
    db.commit()
    return {"message": "Persona eliminada correctamente"}

@router.post("/login", response_model=schemas.Persona)
def login_persona(credentials: schemas.LoginCredentials, db: Session = Depends(get_db)):
    # Query con join para obtener la información del rol
    db_persona = db.query(models.Persona).options(
        joinedload(models.Persona.rol)
    ).filter(
        models.Persona.numero_identificacion == credentials.numero_identificacion
    ).first()
    
    if not db_persona:
        raise HTTPException(
            status_code=401,
            detail="Credenciales incorrectas"
        )
    
    if not verify_password(credentials.password, db_persona.hashed_password):
        raise HTTPException(
            status_code=401,
            detail="Credenciales incorrectas"
        )
    
    # Verificar si el usuario tiene un rol asignado
    if db_persona.rol is None:
        # Si no tiene rol, asignamos uno por defecto (por ejemplo, el rol con ID 1)
        default_rol = db.query(models.Rol).filter(models.Rol.id_rol == 1).first()
        if default_rol:
            db_persona.rol = default_rol
            db_persona.id_rol = default_rol.id_rol
            db.commit()
            db.refresh(db_persona)
        
    return db_persona

@router.get("/by-id/{numero_identificacion}", response_model=schemas.Persona)
def get_persona_by_identificacion(numero_identificacion: str, db: Session = Depends(get_db)):
    db_persona = db.query(models.Persona).filter(
        models.Persona.numero_identificacion == numero_identificacion
    ).first()
    
    if not db_persona:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    return db_persona

@router.post("/reset-password", response_model=dict)
def reset_password(datos: PasswordReset, db: Session = Depends(get_db)):
    db_persona = db.query(models.Persona).filter(
        models.Persona.numero_identificacion == datos.numero_identificacion
    ).first()
    
    if not db_persona:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    # Actualizar la contraseña
    db_persona.hashed_password = get_password_hash(datos.new_password)
    db.commit()
    
    return {"message": "Contraseña actualizada correctamente"}