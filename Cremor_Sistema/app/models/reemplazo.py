# En tu archivo de modelos (ej: app/models/reemplazo.py)
from .base import Base
from enum import Enum
from datetime import date
from sqlalchemy import Column, Integer, String, Date, Enum as EnumDB, ForeignKey
from sqlalchemy.orm import relationship

# Enums para el nuevo modelo
class TipoReemplazo(str, Enum):
    INTERNO = "INTERNO"
    EXTERNO = "EXTERNO"

class EstadoReemplazo(str, Enum):
    ACTIVO = "ACTIVO"
    CANCELADO = "CANCELADO"
    FINALIZADO = "FINALIZADO"

# Modelo de la base de datos para Reemplazo
class Reemplazo(Base):
    __tablename__ = "reemplazo"

    id_reemplazo = Column(Integer, primary_key=True, index=True)
    
    # --- Claves Foráneas a la tabla Persona ---
    # Usamos dos FK a la misma tabla, por lo que debemos ser explícitos.
    id_persona_reemplazada = Column(Integer, ForeignKey("persona.id_persona"), nullable=False)
    id_persona_reemplazo = Column(Integer, ForeignKey("persona.id_persona"), nullable=True)

    # --- Campos del Reemplazo ---
    tipo_reemplazo = Column(EnumDB(TipoReemplazo), nullable=False)
    fecha_inicio = Column(Date, nullable=False)
    fecha_fin = Column(Date, nullable=False)
    motivo = Column(String(255), nullable=False)
    estado = Column(EnumDB(EstadoReemplazo), default=EstadoReemplazo.ACTIVO)
    
    # --- Campos solo para reemplazos EXTERNOS ---
    nombre_externo = Column(String(100), nullable=True)
    contacto_externo = Column(String(100), nullable=True)
    documento_externo = Column(String(20), nullable=True)
    
    # --- Relaciones con Persona ---
    # SQLAlchemy necesita que especifiquemos qué FK usar para cada relación.
    persona_reemplazada = relationship(
        "Persona",
        foreign_keys=[id_persona_reemplazada],
        back_populates="reemplazos_sufridos"
    )
    persona_reemplazo = relationship(
        "Persona",
        foreign_keys=[id_persona_reemplazo],
        back_populates="reemplazos_realizados"
    )