# En app/schemas/notificacion.py

from pydantic import BaseModel
from datetime import datetime
from typing import Optional

# Importamos los Enums del modelo y los esquemas de Persona
from ..models.notificacion import PrioridadNotificacion, EstadoNotificacion, MotivoNotificacion
from .persona import Persona as PersonaSchema

# Esquema base con los campos comunes
class NotificacionBase(BaseModel):
    id_remitente: int
    id_destinatario: int
    asunto: str
    mensaje: str
    prioridad: PrioridadNotificacion = PrioridadNotificacion.MEDIA
    motivo: MotivoNotificacion = MotivoNotificacion.GENERAL

# Esquema para la creación (no necesita validaciones extra en este caso)
class NotificacionCreate(NotificacionBase):
    pass

# Esquema para las respuestas de la API (lo que se devuelve al cliente)
class Notificacion(NotificacionBase):
    id_notificacion: int
    fecha_hora_envio: datetime
    estado: EstadoNotificacion
    
    # Incluimos los objetos completos para dar más contexto
    remitente: PersonaSchema
    destinatario: PersonaSchema

    class Config:
        from_attributes = True