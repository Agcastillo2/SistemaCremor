from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db
from datetime import date

router = APIRouter(prefix="/asignaciones-vc", tags=["asignaciones-vehiculo-conductor"])

@router.post("/", response_model=schemas.AsignacionVC)
def create_asignacion(
    asignacion: schemas.AsignacionVCCreate, 
    db: Session = Depends(get_db)
):
    # Verificar que existan la persona y el vehículo
    persona = db.query(models.Persona).filter(
        models.Persona.id_persona == asignacion.id_persona
    ).first()
    if not persona:
        raise HTTPException(status_code=404, detail="Persona no encontrada")

    vehiculo = db.query(models.Vehiculo).filter(
        models.Vehiculo.id_vehiculo == asignacion.id_vehiculo
    ).first()
    if not vehiculo:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")

    # Verificar si el conductor ya tiene una asignación activa
    asignacion_activa = db.query(models.AsignacionVehiculoConductor).filter(
        models.AsignacionVehiculoConductor.id_persona == asignacion.id_persona,
        models.AsignacionVehiculoConductor.fecha_finalizacion == None
    ).first()
    if asignacion_activa:
        raise HTTPException(
            status_code=400,
            detail="Esta persona ya tiene una asignación activa"
        )

    db_asignacion = models.AsignacionVehiculoConductor(**asignacion.model_dump())
    db.add(db_asignacion)
    db.commit()
    db.refresh(db_asignacion)
    return db_asignacion

@router.get("/", response_model=list[schemas.AsignacionVC])
def read_asignaciones(
    activas: bool = None,
    conductor_id: int = None,
    vehiculo_id: int = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    query = db.query(models.AsignacionVehiculoConductor)
    
    if activas is not None:
        if activas:
            query = query.filter(
                (models.AsignacionVehiculoConductor.fecha_finalizacion == None) |
                (models.AsignacionVehiculoConductor.fecha_finalizacion > date.today())
            )
        else:
            query = query.filter(
                models.AsignacionVehiculoConductor.fecha_finalizacion <= date.today()
            )
    
    if conductor_id:
        query = query.filter(
            models.AsignacionVehiculoConductor.id_persona == conductor_id
        )
    
    if vehiculo_id:
        query = query.filter(
            models.AsignacionVehiculoConductor.id_vehiculo == vehiculo_id
        )
    
    return query.offset(skip).limit(limit).all()

@router.put("/{asignacion_id}/finalizar", response_model=schemas.AsignacionVC)
def finalizar_asignacion(
    asignacion_id: int,
    kilometraje_final: int,
    db: Session = Depends(get_db)
):
    db_asignacion = db.query(models.AsignacionVehiculoConductor).filter(
        models.AsignacionVehiculoConductor.id_asignacion_vc == asignacion_id
    ).first()
    
    if not db_asignacion:
        raise HTTPException(status_code=404, detail="Asignación no encontrada")
    
    if db_asignacion.fecha_finalizacion:
        raise HTTPException(status_code=400, detail="Esta asignación ya está finalizada")
    
    if kilometraje_final < db_asignacion.kilometraje_inicial:
        raise HTTPException(
            status_code=400,
            detail="El kilometraje final no puede ser menor al inicial"
        )
    
    db_asignacion.fecha_finalizacion = date.today()
    db_asignacion.kilometraje_final = kilometraje_final
    
    # Actualizar kilometraje del vehículo
    db_asignacion.vehiculo.kilometraje = kilometraje_final
    
    db.commit()
    db.refresh(db_asignacion)
    return db_asignacion