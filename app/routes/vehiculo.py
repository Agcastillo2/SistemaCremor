from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/vehiculos", tags=["vehiculos"])

@router.post("/", response_model=schemas.Vehiculo)
def create_vehiculo(vehiculo: schemas.VehiculoCreate, db: Session = Depends(get_db)):
    # Verificar si la placa ya existe
    db_vehiculo = db.query(models.Vehiculo).filter(
        models.Vehiculo.placa == vehiculo.placa
    ).first()
    if db_vehiculo:
        raise HTTPException(status_code=400, detail="Placa ya registrada")
    
    db_vehiculo = models.Vehiculo(**vehiculo.model_dump())
    
    db.add(db_vehiculo)
    db.commit()
    db.refresh(db_vehiculo)
    return db_vehiculo

@router.get("/", response_model=list[schemas.Vehiculo])
def read_vehiculos(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    vehiculos = db.query(models.Vehiculo).offset(skip).limit(limit).all()
    return vehiculos

@router.get("/{vehiculo_id}", response_model=schemas.Vehiculo)
def read_vehiculo(vehiculo_id: int, db: Session = Depends(get_db)):
    db_vehiculo = db.query(models.Vehiculo).filter(
        models.Vehiculo.id_vehiculo == vehiculo_id
    ).first()
    if db_vehiculo is None:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")
    return db_vehiculo

@router.put("/{vehiculo_id}", response_model=schemas.Vehiculo)
def update_vehiculo(
    vehiculo_id: int, 
    vehiculo: schemas.VehiculoCreate, 
    db: Session = Depends(get_db)
):
    db_vehiculo = db.query(models.Vehiculo).filter(
        models.Vehiculo.id_vehiculo == vehiculo_id
    ).first()
    if db_vehiculo is None:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")
    
    # Verificar si la nueva placa ya existe (excepto para este vehículo)
    if vehiculo.placa != db_vehiculo.placa:
        existing = db.query(models.Vehiculo).filter(
            models.Vehiculo.placa == vehiculo.placa
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="Placa ya registrada en otro vehículo")
    
    for field, value in vehiculo.model_dump().items():
        setattr(db_vehiculo, field, value)
    
    db.commit()
    db.refresh(db_vehiculo)
    return db_vehiculo

@router.delete("/{vehiculo_id}")
def delete_vehiculo(vehiculo_id: int, db: Session = Depends(get_db)):
    db_vehiculo = db.query(models.Vehiculo).filter(
        models.Vehiculo.id_vehiculo == vehiculo_id
    ).first()
    if db_vehiculo is None:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")
    
    db.delete(db_vehiculo)
    db.commit()
    return {"message": "Vehículo eliminado correctamente"}