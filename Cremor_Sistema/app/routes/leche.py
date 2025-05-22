from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db
from datetime import date

router = APIRouter(prefix="/leche", tags=["leche"])

@router.post("/", response_model=schemas.Leche)
def create_leche(leche: schemas.LecheCreate, db: Session = Depends(get_db)):
    # Verificar si ya existe registro para esta fecha y proveedor
    db_leche = db.query(models.Leche).filter(
        models.Leche.fecha == leche.fecha,
        models.Leche.proveedor == leche.proveedor
    ).first()
    if db_leche:
        raise HTTPException(
            status_code=400,
            detail="Ya existe un registro para esta fecha y proveedor"
        )
    
    db_leche = models.Leche(**leche.model_dump())
    db.add(db_leche)
    db.commit()
    db.refresh(db_leche)
    return db_leche

@router.get("/", response_model=list[schemas.Leche])
def read_leches(
    skip: int = 0, 
    limit: int = 100,
    fecha_inicio: date = None,
    fecha_fin: date = None,
    proveedor: str = None,
    db: Session = Depends(get_db)
):
    query = db.query(models.Leche)
    
    if fecha_inicio:
        query = query.filter(models.Leche.fecha >= fecha_inicio)
    if fecha_fin:
        query = query.filter(models.Leche.fecha <= fecha_fin)
    if proveedor:
        query = query.filter(models.Leche.proveedor.ilike(f"%{proveedor}%"))
    
    return query.offset(skip).limit(limit).all()

@router.get("/{leche_id}", response_model=schemas.Leche)
def read_leche(leche_id: int, db: Session = Depends(get_db)):
    db_leche = db.query(models.Leche).filter(
        models.Leche.id_leche == leche_id
    ).first()
    if db_leche is None:
        raise HTTPException(status_code=404, detail="Registro de leche no encontrado")
    return db_leche

@router.put("/{leche_id}", response_model=schemas.Leche)
def update_leche(
    leche_id: int, 
    leche: schemas.LecheCreate, 
    db: Session = Depends(get_db)
):
    db_leche = db.query(models.Leche).filter(
        models.Leche.id_leche == leche_id
    ).first()
    if db_leche is None:
        raise HTTPException(status_code=404, detail="Registro de leche no encontrado")
    
    # Verificar si los nuevos fecha/proveedor ya existen (en otro registro)
    if leche.fecha != db_leche.fecha or leche.proveedor != db_leche.proveedor:
        existing = db.query(models.Leche).filter(
            models.Leche.fecha == leche.fecha,
            models.Leche.proveedor == leche.proveedor,
            models.Leche.id_leche != leche_id
        ).first()
        if existing:
            raise HTTPException(
                status_code=400,
                detail="Ya existe otro registro para esta fecha y proveedor"
            )
    
    for field, value in leche.model_dump().items():
        setattr(db_leche, field, value)
    
    db.commit()
    db.refresh(db_leche)
    return db_leche

@router.delete("/{leche_id}")
def delete_leche(leche_id: int, db: Session = Depends(get_db)):
    db_leche = db.query(models.Leche).filter(
        models.Leche.id_leche == leche_id
    ).first()
    if db_leche is None:
        raise HTTPException(status_code=404, detail="Registro de leche no encontrado")
    
    db.delete(db_leche)
    db.commit()
    return {"message": "Registro de leche eliminado correctamente"}