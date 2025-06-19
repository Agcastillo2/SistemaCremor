from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..schemas.proceso import ProcesoCreate, ProcesoUpdate, ProcesoOut
from ..models.proceso import Proceso
from ..models.persona import Persona
from datetime import datetime
import pytz

router = APIRouter(
    prefix="/procesos",
    tags=["procesos"]
)
tz = pytz.timezone('America/Guayaquil')  # GMT-5

@router.post("/", response_model=ProcesoOut)
def crear_proceso(proceso: ProcesoCreate, db: Session = Depends(get_db)):
    # Verificar que existe la persona
    persona = db.query(Persona).filter(Persona.id_persona == proceso.id_persona).first()
    if not persona:
        raise HTTPException(status_code=404, detail="Persona no encontrada")

    # Crear el proceso
    db_proceso = Proceso(
        fecha=datetime.now(tz),
        proceso_x=proceso.proceso_x,
        proceso_y=proceso.proceso_y,
        estado="En progreso",
        leche_ingresada=proceso.leche_ingresada,
        id_persona=proceso.id_persona
    )
    
    db.add(db_proceso)
    db.commit()
    db.refresh(db_proceso)
    
    return {
        **db_proceso.__dict__,
        "nombre_persona": f"{persona.nombres} {persona.apellidos}"
    }

@router.put("/{id_proceso}", response_model=ProcesoOut)
def finalizar_proceso(id_proceso: int, datos: ProcesoUpdate, id_persona: int, db: Session = Depends(get_db)):
    proceso = db.query(Proceso).filter(Proceso.id_proceso == id_proceso).first()
    if not proceso:
        raise HTTPException(status_code=404, detail="Proceso no encontrado")
    
    # Verificar que la persona que intenta finalizar el proceso es la misma que lo creó
    if proceso.id_persona != id_persona:
        raise HTTPException(
            status_code=403,
            detail="No tienes permiso para finalizar este proceso. Solo el jefe que inició el proceso puede finalizarlo."
        )
    
    proceso.estado = datos.estado
    proceso.produccion_kg = datos.produccion_kg
    if datos.leche_sobrante is not None:
        proceso.leche_sobrante = datos.leche_sobrante
    
    db.commit()
    db.refresh(proceso)
    
    persona = db.query(Persona).filter(Persona.id_persona == proceso.id_persona).first()
    return {
        **proceso.__dict__,
        "nombre_persona": f"{persona.nombres} {persona.apellidos}"
    }

@router.get("/ultimo", response_model=ProcesoOut)
def obtener_ultimo_proceso(db: Session = Depends(get_db)):
    proceso = db.query(Proceso).order_by(Proceso.fecha.desc()).first()
    if not proceso:
        raise HTTPException(status_code=404, detail="No hay procesos registrados")
    
    persona = db.query(Persona).filter(Persona.id_persona == proceso.id_persona).first()
    return {
        **proceso.__dict__,
        "nombre_persona": f"{persona.nombres} {persona.apellidos}"
    }

@router.get("/", response_model=List[ProcesoOut])
def listar_procesos(skip: int = 0, limit: int = 6, db: Session = Depends(get_db)):
    procesos = db.query(Proceso).order_by(Proceso.fecha.desc()).offset(skip).limit(limit).all()
    
    resultado = []
    for proceso in procesos:
        persona = db.query(Persona).filter(Persona.id_persona == proceso.id_persona).first()
        resultado.append({
            **proceso.__dict__,
            "nombre_persona": f"{persona.nombres} {persona.apellidos}"
        })
    
    return resultado
