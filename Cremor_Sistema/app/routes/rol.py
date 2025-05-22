from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/roles", tags=["roles"])

@router.post("/", response_model=schemas.Rol)
def create_rol(rol: schemas.RolCreate, db: Session = Depends(get_db)):
    db_rol = models.Rol(**rol.model_dump())
    db.add(db_rol)
    db.commit()
    db.refresh(db_rol)
    return db_rol

@router.get("/", response_model=list[schemas.Rol])
def read_roles(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    roles = db.query(models.Rol).offset(skip).limit(limit).all()
    return roles

@router.get("/{rol_id}", response_model=schemas.Rol)
def read_rol(rol_id: int, db: Session = Depends(get_db)):
    db_rol = db.query(models.Rol).filter(models.Rol.id_rol == rol_id).first()
    if db_rol is None:
        raise HTTPException(status_code=404, detail="Rol no encontrado")
    return db_rol

@router.put("/{rol_id}", response_model=schemas.Rol)
def update_rol(rol_id: int, rol: schemas.RolCreate, db: Session = Depends(get_db)):
    db_rol = db.query(models.Rol).filter(models.Rol.id_rol == rol_id).first()
    if db_rol is None:
        raise HTTPException(status_code=404, detail="Rol no encontrado")
    
    for field, value in rol.model_dump().items():
        setattr(db_rol, field, value)
    
    db.commit()
    db.refresh(db_rol)
    return db_rol

@router.delete("/{rol_id}")
def delete_rol(rol_id: int, db: Session = Depends(get_db)):
    db_rol = db.query(models.Rol).filter(models.Rol.id_rol == rol_id).first()
    if db_rol is None:
        raise HTTPException(status_code=404, detail="Rol no encontrado")
    
    db.delete(db_rol)
    db.commit()
    return {"message": "Rol eliminado correctamente"}