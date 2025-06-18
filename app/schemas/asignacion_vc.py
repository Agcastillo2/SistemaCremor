from datetime import date
from enum import Enum
from pydantic import BaseModel, validator
from typing import Optional

class MotivoAsignacion(str, Enum):
    SERVICIO = "SERVICIO"
    EMERGENCIA = "EMERGENCIA"
    REEMPLAZO = "REEMPLAZO"
    VIAJE = "VIAJE"
    CARGA = "CARGA"
    OTRO = "OTRO"

class AsignacionVCBase(BaseModel):
    id_persona: int
    id_vehiculo: int
    fecha_asignacion: date
    fecha_finalizacion: Optional[date] = None
    motivo: Optional[MotivoAsignacion] = None
    kilometraje_inicial: int
    kilometraje_final: Optional[int] = None

    @validator('kilometraje_inicial', 'kilometraje_final')
    def validate_kilometraje(cls, v):
        if v is not None and v < 0:
            raise ValueError("El kilometraje no puede ser negativo")
        return v

    @validator('fecha_finalizacion')
    def validate_fechas(cls, v, values):
        if v is not None and 'fecha_asignacion' in values and v < values['fecha_asignacion']:
            raise ValueError("La fecha de finalización no puede ser anterior a la de asignación")
        return v

class AsignacionVCCreate(AsignacionVCBase):
    pass

class AsignacionVC(AsignacionVCBase):
    id_asignacion_vc: int
    activa: bool

    class Config:
        from_attributes = True