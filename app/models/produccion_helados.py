from datetime import datetime
from sqlalchemy import Column, Integer, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from .base import Base

class ProduccionHelados(Base):
    __tablename__ = "produccion_helados"

    id = Column(Integer, primary_key=True, index=True)
    fecha = Column(DateTime, default=datetime.utcnow)
    id_persona = Column(Integer, ForeignKey('persona.id_persona'))

    leche_ingresada = Column(Float, nullable=False)
    vainilla_ingresada = Column(Float, nullable=False)
    chocolate_ingresada = Column(Float, nullable=False)
    fresa_ingresada = Column(Float, nullable=False)
    menta_ingresada = Column(Float, nullable=False)

    unidades_vainilla = Column(Integer, nullable=True)
    unidades_chocolate = Column(Integer, nullable=True)
    unidades_fresa = Column(Integer, nullable=True)
    unidades_menta = Column(Integer, nullable=True)

    leche_sobrante = Column(Float, nullable=True)
    vainilla_sobrante = Column(Float, nullable=True)
    chocolate_sobrante = Column(Float, nullable=True)
    fresa_sobrante = Column(Float, nullable=True)
    menta_sobrante = Column(Float, nullable=True)

    persona = relationship("Persona", back_populates="producciones_helados")

    @property
    def responsable(self):
        return self.persona.nombre_completo if self.persona else ''

    @property
    def finalizado(self):
        # A process is considered finalized if units were assigned
        return self.unidades_vainilla is not None
