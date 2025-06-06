# app/routes/puesto.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db
from typing import List

router = APIRouter(
    prefix="/puestos",
    tags=["puestos"]
)

@router.post("/", response_model=schemas.Puesto, status_code=status.HTTP_201_CREATED)
def create_puesto(puesto: schemas.PuestoCreate, db: Session = Depends(get_db)):
    # Verificar si ya existe un puesto con la misma descripción
    db_puesto = db.query(models.Puesto).filter(models.Puesto.descripcion == puesto.descripcion).first()
    if db_puesto:
        raise HTTPException(status_code=400, detail="Ya existe un puesto con esa descripción")
    
    new_puesto = models.Puesto(**puesto.model_dump())
    db.add(new_puesto)
    db.commit()
    db.refresh(new_puesto)
    return new_puesto

@router.get("/", response_model=List[schemas.Puesto])
def read_puestos(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    puestos = db.query(models.Puesto).offset(skip).limit(limit).all()
    return puestos

@router.get("/{puesto_id}", response_model=schemas.Puesto)
def read_puesto(puesto_id: int, db: Session = Depends(get_db)):
    db_puesto = db.query(models.Puesto).filter(models.Puesto.id_puesto == puesto_id).first()
    if db_puesto is None:
        raise HTTPException(status_code=404, detail="Puesto no encontrado")
    return db_puesto

@router.put("/{puesto_id}", response_model=schemas.Puesto)
def update_puesto(puesto_id: int, puesto: schemas.PuestoUpdate, db: Session = Depends(get_db)):
    db_puesto = db.query(models.Puesto).filter(models.Puesto.id_puesto == puesto_id).first()
    if db_puesto is None:
        raise HTTPException(status_code=404, detail="Puesto no encontrado")
    
    update_data = puesto.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_puesto, key, value)
    
    db.commit()
    db.refresh(db_puesto)
    return db_puesto

@router.delete("/{puesto_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_puesto(puesto_id: int, db: Session = Depends(get_db)):
    db_puesto = db.query(models.Puesto).filter(models.Puesto.id_puesto == puesto_id).first()
    if db_puesto is None:
        raise HTTPException(status_code=404, detail="Puesto no encontrado")
    
    # Consideración: Antes de borrar, podrías verificar si algún empleado tiene este puesto asignado.
    # Si es así, podrías impedir la eliminación para mantener la integridad de los datos.

    db.delete(db_puesto)
    db.commit()
    return