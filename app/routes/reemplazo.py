# En app/routes/reemplazo.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from typing import List
from .. import models, schemas
from ..database import get_db

router = APIRouter(
    prefix="/reemplazos",
    tags=["reemplazos"]
)

@router.post("/", response_model=schemas.Reemplazo, status_code=201)
def create_reemplazo(reemplazo: schemas.ReemplazoCreate, db: Session = Depends(get_db)):
    # 1. Verificar que la persona a ser reemplazada exista
    persona_reemplazada = db.query(models.Persona).filter(models.Persona.id_persona == reemplazo.id_persona_reemplazada).first()
    if not persona_reemplazada:
        raise HTTPException(status_code=404, detail=f"La persona a ser reemplazada con id={reemplazo.id_persona_reemplazada} no existe.")

    # --- LÓGICA CORREGIDA AQUÍ ---
    # Comparamos con el Enum del módulo 'models', no 'schemas'
    if reemplazo.tipo_reemplazo == models.TipoReemplazo.INTERNO:
        persona_reemplazo = db.query(models.Persona).filter(models.Persona.id_persona == reemplazo.id_persona_reemplazo).first()
        if not persona_reemplazo:
            raise HTTPException(status_code=404, detail=f"La persona de reemplazo con id={reemplazo.id_persona_reemplazo} no existe.")

    # 2. Crear la instancia del modelo de BD
    db_reemplazo = models.Reemplazo(**reemplazo.model_dump())
    
    db.add(db_reemplazo)
    db.commit()
    db.refresh(db_reemplazo)
    return db_reemplazo

@router.get("/", response_model=List[schemas.Reemplazo])
def read_reemplazos(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    # Usamos joinedload para cargar eficientemente las relaciones de Persona
    reemplazos = db.query(models.Reemplazo).options(
        joinedload(models.Reemplazo.persona_reemplazada),
        joinedload(models.Reemplazo.persona_reemplazo)
    ).offset(skip).limit(limit).all()
    return reemplazos

@router.get("/{reemplazo_id}", response_model=schemas.Reemplazo)
def read_reemplazo(reemplazo_id: int, db: Session = Depends(get_db)):
    db_reemplazo = db.query(models.Reemplazo).options(
        joinedload(models.Reemplazo.persona_reemplazada),
        joinedload(models.Reemplazo.persona_reemplazo)
    ).filter(models.Reemplazo.id_reemplazo == reemplazo_id).first()
    
    if db_reemplazo is None:
        raise HTTPException(status_code=404, detail="Reemplazo no encontrado")
    return db_reemplazo