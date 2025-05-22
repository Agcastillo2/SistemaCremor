from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db
from passlib.context import CryptContext

router = APIRouter(prefix="/personas", tags=["personas"])

# Configuración para el hashing de contraseñas
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

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
    
    # Actualizar campos
    for field, value in persona.model_dump(exclude={"password"}).items():
        setattr(db_persona, field, value)
    
    # Actualizar contraseña si se proporciona
    if persona.password:
        db_persona.hashed_password = get_password_hash(persona.password)
    
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