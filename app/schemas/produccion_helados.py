from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional, List

class InsumosDisponibles(BaseModel):
    leche: float = 0
    vainilla: float = 0
    chocolate: float = 0
    fresa: float = 0
    menta: float = 0

class ProduccionHeladosCreate(BaseModel):
    leche_ingresada: float = Field(..., ge=0)
    vainilla_ingresada: float = Field(..., ge=0)
    chocolate_ingresada: float = Field(..., ge=0)
    fresa_ingresada: float = Field(..., ge=0)
    menta_ingresada: float = Field(..., ge=0)

class ResultadoPosible(BaseModel):
    unidades_vainilla: int
    unidades_chocolate: int
    unidades_fresa: int
    unidades_menta: int

class FinalizarProceso(BaseModel):
    unidades_vainilla: int = Field(..., ge=0)
    unidades_chocolate: int = Field(..., ge=0)
    unidades_fresa: int = Field(..., ge=0)
    unidades_menta: int = Field(..., ge=0)

class ProduccionHeladosOut(BaseModel):
    id: int
    fecha: datetime
    id_persona: int
    leche_ingresada: float
    vainilla_ingresada: float
    chocolate_ingresada: float
    fresa_ingresada: float
    menta_ingresada: float
    leche_sobrante: Optional[float]
    vainilla_sobrante: Optional[float]
    chocolate_sobrante: Optional[float]
    fresa_sobrante: Optional[float]
    menta_sobrante: Optional[float]
    unidades_vainilla: Optional[int]
    unidades_chocolate: Optional[int]
    unidades_fresa: Optional[int]
    unidades_menta: Optional[int]
    responsable: str
    finalizado: bool

    class Config:
        orm_mode = True
