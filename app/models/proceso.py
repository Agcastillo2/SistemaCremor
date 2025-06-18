from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey
from sqlalchemy.orm import relationship
from .base import Base

class Proceso(Base):
    __tablename__ = 'proceso'

    id_proceso = Column(Integer, primary_key=True, index=True)
    fecha = Column(DateTime, default=datetime.utcnow)
    proceso_x = Column(Integer)
    proceso_y = Column(Integer)
    estado = Column(String)
    leche_ingresada = Column(Float)
    leche_sobrante = Column(Float, nullable=True)
    produccion_kg = Column(Float)
    id_persona = Column(Integer, ForeignKey('persona.id_persona'))
    
    # Relación con la tabla persona
    persona = relationship("Persona", back_populates="procesos")

    class Config:
        orm_mode = True
