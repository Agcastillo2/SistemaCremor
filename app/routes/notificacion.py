# En app/routes/notificacion.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional
from .. import models, schemas
from ..database import get_db

router = APIRouter(
    prefix="/notificaciones",
    tags=["notificaciones"]
)

@router.post("/", response_model=schemas.Notificacion, status_code=status.HTTP_201_CREATED)
def create_notificacion(notificacion: schemas.NotificacionCreate, db: Session = Depends(get_db)):
    """
    Crea y envía una nueva notificación.
    """
    # 1. Verificar que el remitente y el destinatario existan
    if not db.query(models.Persona).filter(models.Persona.id_persona == notificacion.id_remitente).first():
        raise HTTPException(status_code=404, detail=f"El remitente con id={notificacion.id_remitente} no existe.")
    
    if not db.query(models.Persona).filter(models.Persona.id_persona == notificacion.id_destinatario).first():
        raise HTTPException(status_code=404, detail=f"El destinatario con id={notificacion.id_destinatario} no existe.")

    # 2. Crear la instancia del modelo de BD
    db_notificacion = models.Notificacion(**notificacion.model_dump())
    
    db.add(db_notificacion)
    db.commit()
    db.refresh(db_notificacion)
    return db_notificacion

@router.get("/", response_model=List[schemas.Notificacion])
def read_notificaciones(
    destinatario_id: Optional[int] = None, # Parámetro opcional para filtrar
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(get_db)
):
    """
    Obtiene una lista de notificaciones.
    Opcionalmente, puede filtrar por el ID del destinatario.
    """
    query = db.query(models.Notificacion).options(
        joinedload(models.Notificacion.remitente),
        joinedload(models.Notificacion.destinatario)
    )
    
    if destinatario_id:
        query = query.filter(models.Notificacion.id_destinatario == destinatario_id)
        
    notificaciones = query.order_by(models.Notificacion.fecha_hora_envio.desc()).offset(skip).limit(limit).all()
    return notificaciones

@router.get("/{notificacion_id}", response_model=schemas.Notificacion)
def read_notificacion(notificacion_id: int, db: Session = Depends(get_db)):
    """
    Obtiene una notificación específica por su ID.
    """
    db_notificacion = db.query(models.Notificacion).options(
        joinedload(models.Notificacion.remitente),
        joinedload(models.Notificacion.destinatario)
    ).filter(models.Notificacion.id_notificacion == notificacion_id).first()
    
    if db_notificacion is None:
        raise HTTPException(status_code=404, detail="Notificación no encontrada")
    return db_notificacion

@router.delete("/{notificacion_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_notificacion(notificacion_id: int, db: Session = Depends(get_db)):
    """
    Elimina una notificación de la base de datos (borrado físico).
    """
    db_notificacion = db.query(models.Notificacion).filter(models.Notificacion.id_notificacion == notificacion_id).first()
    if db_notificacion is None:
        raise HTTPException(status_code=404, detail="Notificación no encontrada")
    
    db.delete(db_notificacion)
    db.commit()
    return None # Para el código 204, no se debe devolver contenido

# En app/routes/notificacion.py

# ... (otros imports y endpoints) ...

@router.patch("/{notificacion_id}/marcar-leido", response_model=schemas.Notificacion)
def mark_notification_as_read(notificacion_id: int, db: Session = Depends(get_db)):
    """
    Cambia el estado de una notificación a 'LEIDO'.
    Este es un método idempotente: si ya está 'LEIDO', no hace nada y devuelve éxito.
    """
    # 1. Buscar la notificación en la base de datos
    db_notificacion = db.query(models.Notificacion).filter(
        models.Notificacion.id_notificacion == notificacion_id
    ).first()

    # 2. Si no se encuentra, devolver un error 404
    if db_notificacion is None:
        raise HTTPException(status_code=404, detail="Notificación no encontrada")

    # 3. Cambiar el estado
    # Usamos el Enum del modelo para asegurar la consistencia
    db_notificacion.estado = models.EstadoNotificacion.LEIDO
    
    # 4. Guardar los cambios en la base de datos
    db.commit()
    db.refresh(db_notificacion)
    
    # 5. Devolver la notificación actualizada
    return db_notificacion