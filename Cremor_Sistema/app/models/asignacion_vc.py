from .base import Base
from datetime import date
from enum import Enum
from sqlalchemy import Column, Integer, Date, ForeignKey
from sqlalchemy.orm import relationship, declarative_base
from sqlalchemy import event
from sqlalchemy import Enum as EnumDB

Base = declarative_base()

class MotivoAsignacion(str, Enum):
    SERVICIO = "SERVICIO"
    EMERGENCIA = "EMERGENCIA"
    REEMPLAZO = "REEMPLAZO"
    VIAJE = "VIAJE"
    CARGA = "CARGA"
    OTRO = "OTRO"

class AsignacionVehiculoConductor(Base):
    __tablename__ = "asignacion_vehiculo_conductor"

    id_asignacion_vc = Column(Integer, primary_key=True, index=True)
    id_persona = Column(Integer, ForeignKey('persona.id_persona'), nullable=False)
    id_vehiculo = Column(Integer, ForeignKey('vehiculo.id_vehiculo'), nullable=False)
    fecha_asignacion = Column(Date, nullable=False, default=date.today())
    fecha_finalizacion = Column(Date)
    motivo = Column(EnumDB(MotivoAsignacion))  # Eliminado el parámetro length
    kilometraje_inicial = Column(Integer, nullable=False)
    kilometraje_final = Column(Integer)

    # Relaciones
    persona = relationship("Persona", back_populates="asignaciones_vehiculos")
    vehiculo = relationship("Vehiculo", back_populates="asignaciones_conductores")  
    

    @property
    def activa(self):
        return self.fecha_finalizacion is None or self.fecha_finalizacion > date.today()

# Validación de fechas
@event.listens_for(AsignacionVehiculoConductor, 'before_insert')
@event.listens_for(AsignacionVehiculoConductor, 'before_update')
def validar_fechas(mapper, connection, target):
    if target.fecha_finalizacion and target.fecha_finalizacion < target.fecha_asignacion:
        raise ValueError("La fecha de finalización no puede ser anterior a la de asignación")