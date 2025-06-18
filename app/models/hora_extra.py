# En app/models/hora_extra.py

from .base import Base
from enum import Enum
from datetime import date, datetime
from sqlalchemy import Column, Integer, String, Date, DateTime, Enum as EnumDB, ForeignKey, Float
from sqlalchemy.orm import relationship

# Enums para el nuevo modelo
class TipoRegistroHoraExtra(str, Enum):
    DIA = "DIA"
    HORA = "HORA"

class TipoPagoDia(str, Enum):
    NORMAL = "NORMAL"
    ESPECIAL = "ESPECIAL" # Para feriados, etc.

class EstadoHoraExtra(str, Enum):
    PENDIENTE = "PENDIENTE"
    APROBADO = "APROBADO"
    PAGADO = "PAGADO"

# Modelo de la base de datos para HoraExtra
class Hora_Extra(Base):
    __tablename__ = "hora_extra"

    id_hora_extra = Column(Integer, primary_key=True, index=True)
    
    # --- Claves Foráneas ---
    id_persona = Column(Integer, ForeignKey("persona.id_persona"), nullable=False)
    id_puesto = Column(Integer, ForeignKey("puesto.id_puesto"), nullable=False)
    
    # --- Campos Generales ---
    tipo_registro = Column(EnumDB(TipoRegistroHoraExtra), nullable=False)
    motivo = Column(String(255), nullable=False)
    estado = Column(EnumDB(EstadoHoraExtra), default=EstadoHoraExtra.PENDIENTE)

    # --- Campos para registro por DÍA ---
    fecha_dia = Column(Date, nullable=True)
    tipo_pago_dia = Column(EnumDB(TipoPagoDia), nullable=True)
    cantidad_dias = Column(Integer, nullable=True)

    # --- Campos para registro por HORA ---
    fecha_hora_inicio = Column(DateTime, nullable=True)
    fecha_hora_fin = Column(DateTime, nullable=True)
    horas_calculadas = Column(Float, nullable=True) # Usamos Float para horas con decimales (ej: 2.5 horas)

    # --- Relaciones ---
    persona = relationship("Persona", back_populates="horas_extras")
    puesto = relationship("Puesto", back_populates="horas_extras")