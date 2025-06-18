from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from .. import models, schemas
from ..database import get_db
from datetime import datetime
import pytz

router = APIRouter(
    prefix="/asistencia",
    tags=["asistencia"]
)

def get_local_time():
    # Configurar la zona horaria de Colombia
    tz = pytz.timezone('America/Bogota')
    # Obtener la hora actual en Colombia
    return datetime.now(tz)

@router.post("/entrada", response_model=schemas.RegistroEntradaSalida)
def marcar_entrada(registro: schemas.RegistroEntradaCreate, db: Session = Depends(get_db)):
    # Verificar sesión activa
    registro_activo = db.query(models.RegistroEntradaSalida).filter(
        models.RegistroEntradaSalida.id_persona == registro.id_persona,
        models.RegistroEntradaSalida.fecha_hora_salida == None
    ).first()
    
    if registro_activo:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe una sesión activa para esta persona"
        )

    nuevo_registro = models.RegistroEntradaSalida(
        **registro.model_dump(),
        fecha_hora_entrada=get_local_time(),  # Usar la hora local de Colombia
        estado=models.EstadoAsistencia.PRESENTE
    )
    
    db.add(nuevo_registro)
    db.commit()
    db.refresh(nuevo_registro)
    return nuevo_registro

@router.put("/salida/{persona_id}", response_model=schemas.RegistroEntradaSalida)
def marcar_salida(persona_id: int, datos_salida: schemas.RegistroSalidaUpdate, db: Session = Depends(get_db)):
    registro_activo = db.query(models.RegistroEntradaSalida).filter(
        models.RegistroEntradaSalida.id_persona == persona_id,
        models.RegistroEntradaSalida.fecha_hora_salida == None
    ).first()

    if not registro_activo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No se encontró una sesión activa"
        )

    registro_activo.fecha_hora_salida = get_local_time()  # Usar la hora local de Colombia
    if datos_salida.observaciones:
        registro_activo.observaciones = datos_salida.observaciones

    db.commit()
    db.refresh(registro_activo)
    return registro_activo

@router.get("/", response_model=List[schemas.RegistroEntradaSalida])
def listar_registros(
    persona_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    query = db.query(models.RegistroEntradaSalida).options(
        joinedload(models.RegistroEntradaSalida.puesto)
    )
    if persona_id:
        query = query.filter(models.RegistroEntradaSalida.id_persona == persona_id)
    return query.order_by(models.RegistroEntradaSalida.fecha_hora_entrada.desc()).offset(skip).limit(limit).all()

@router.get("/activo/{persona_id}", response_model=schemas.RegistroEntradaSalida)
def obtener_registro_activo(persona_id: int, db: Session = Depends(get_db)):
    registro_activo = db.query(models.RegistroEntradaSalida).filter(
        models.RegistroEntradaSalida.id_persona == persona_id,
        models.RegistroEntradaSalida.fecha_hora_salida == None
    ).options(joinedload(models.RegistroEntradaSalida.puesto)).first()

    if not registro_activo:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No hay un registro activo para esta persona"
        )

    return registro_activo