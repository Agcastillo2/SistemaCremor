# app/models/puesto.py

from .base import Base
from sqlalchemy import Column, Integer, String, Boolean
from sqlalchemy.orm import relationship

class Puesto(Base):
    __tablename__ = "puesto"

    id_puesto = Column(Integer, primary_key=True, index=True)
    descripcion = Column(String(100), nullable=False, unique=True)
    activo = Column(Boolean, nullable=False, default=True)

    # --- Relaciones ---
    
    # Un puesto puede tener muchos registros de entrada/salida asociados.
    registros_asistencia = relationship("RegistroEntradaSalida", back_populates="puesto")

    # Un puesto puede tener muchas horas extras asociadas.
    horas_extras = relationship("Hora_Extra", back_populates="puesto")