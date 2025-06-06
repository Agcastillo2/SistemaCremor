from .base import Base
from enum import Enum
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Enum as EnumDB, ForeignKey
from sqlalchemy.orm import relationship

class EstadoAsistencia(str, Enum):
    PRESENTE = "PRESENTE"
    AUSENTE = "AUSENTE"
    PERMISO = "PERMISO"
    VACACIONES = "VACACIONES"

class TipoTurno(str, Enum):
    MANANA = "MAÑANA"
    TARDE = "TARDE"
    NOCHE = "NOCHE"
    COMPLETO = "COMPLETO"

class RegistroEntradaSalida(Base):
    __tablename__ = "registro_entrada_salida"

    id_registro = Column(Integer, primary_key=True, index=True)
    id_persona = Column(Integer, ForeignKey("persona.id_persona"), nullable=False)
    id_rol = Column(Integer, ForeignKey("rol.id_rol"), nullable=False)
    id_puesto = Column(Integer, ForeignKey("puesto.id_puesto"), nullable=False)
    fecha_hora_entrada = Column(DateTime, default=datetime.utcnow)
    fecha_hora_salida = Column(DateTime, nullable=True)
    estado = Column(EnumDB(EstadoAsistencia), default=EstadoAsistencia.PRESENTE)
    turno = Column(EnumDB(TipoTurno), nullable=False)
    observaciones = Column(String(255), nullable=True)

    persona = relationship("Persona", back_populates="registros_asistencia")
    rol = relationship("Rol")
    puesto = relationship("Puesto")