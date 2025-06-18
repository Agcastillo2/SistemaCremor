# En app/models/notificacion.py

from .base import Base
from enum import Enum
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Enum as EnumDB, ForeignKey, Text
from sqlalchemy.orm import relationship

# Enums para el modelo Notificacion
class PrioridadNotificacion(str, Enum):
    BAJA = "BAJA"
    MEDIA = "MEDIA"
    ALTA = "ALTA"
    URGENTE = "URGENTE"

class EstadoNotificacion(str, Enum):
    NO_LEIDO = "NO_LEIDO"
    LEIDO = "LEIDO"
    ARCHIVADO = "ARCHIVADO"

class MotivoNotificacion(str, Enum):
    HORAS_EXTRAS = "Horas Extras"
    REEMPLAZO = "Reemplazo"
    GENERAL = "General"
    ASIGNACION = "Asignación de Vehículo"

# Modelo de la base de datos para Notificacion
class Notificacion(Base):
    __tablename__ = "notificacion"

    id_notificacion = Column(Integer, primary_key=True, index=True)
    
    # Dos claves foráneas a la misma tabla 'persona'
    id_remitente = Column(Integer, ForeignKey("persona.id_persona"), nullable=False)
    id_destinatario = Column(Integer, ForeignKey("persona.id_persona"), nullable=False)

    asunto = Column(String(100), nullable=False)
    mensaje = Column(Text, nullable=False) # Usamos Text para mensajes largos
    fecha_hora_envio = Column(DateTime, default=datetime.utcnow)
    
    prioridad = Column(EnumDB(PrioridadNotificacion), default=PrioridadNotificacion.MEDIA)
    estado = Column(EnumDB(EstadoNotificacion), default=EstadoNotificacion.NO_LEIDO)
    motivo = Column(EnumDB(MotivoNotificacion), default=MotivoNotificacion.GENERAL)

    # Relaciones con Persona, especificando las claves foráneas
    remitente = relationship(
        "Persona",
        foreign_keys=[id_remitente],
        back_populates="notificaciones_enviadas"
    )
    destinatario = relationship(
        "Persona",
        foreign_keys=[id_destinatario],
        back_populates="notificaciones_recibidas"
    )