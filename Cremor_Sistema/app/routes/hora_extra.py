# En app/routes/hora_extra.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from typing import List
from .. import models, schemas
from ..database import get_db

router = APIRouter(
    prefix="/horas-extras",
    tags=["horas-extras"]
)

@router.post("/", response_model=schemas.HoraExtra, status_code=201)
def create_hora_extra(hora_extra: schemas.HoraExtraCreate, db: Session = Depends(get_db)):
    # 1. Validar que la persona y el puesto existan
    if not db.query(models.Persona).filter(models.Persona.id_persona == hora_extra.id_persona).first():
        raise HTTPException(status_code=404, detail=f"La persona con id={hora_extra.id_persona} no existe.")
    
    if not db.query(models.Puesto).filter(models.Puesto.id_puesto == hora_extra.id_puesto).first():
        raise HTTPException(status_code=404, detail=f"El puesto con id={hora_extra.id_puesto} no existe.")

    # 2. Crear la instancia del modelo de BD
    db_hora_extra = models.Hora_Extra(**hora_extra.model_dump())
    
    # Opcional: Calcular las horas si el registro es por HORA
    if db_hora_extra.tipo_registro == models.TipoRegistroHoraExtra.HORA:
        if db_hora_extra.fecha_hora_fin > db_hora_extra.fecha_hora_inicio:
            diferencia = db_hora_extra.fecha_hora_fin - db_hora_extra.fecha_hora_inicio
            db_hora_extra.horas_calculadas = round(diferencia.total_seconds() / 3600, 2)

    db.add(db_hora_extra)
    db.commit()
    db.refresh(db_hora_extra)
    return db_hora_extra

@router.get("/", response_model=List[schemas.HoraExtra])
def read_horas_extras(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    # Usamos joinedload para cargar eficientemente las relaciones
    horas_extras = db.query(models.Hora_Extra).options(
        joinedload(models.Hora_Extra.persona),
        joinedload(models.Hora_Extra.puesto)
    ).offset(skip).limit(limit).all()
    return horas_extras