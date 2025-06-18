from datetime import datetime
from pydantic import BaseModel
from typing import Optional

class ProcesoBase(BaseModel):
    proceso_x: int
    proceso_y: int
    leche_ingresada: float

class ProcesoCreate(ProcesoBase):
    id_persona: int

class ProcesoUpdate(BaseModel):
    estado: str
    produccion_kg: float
    leche_sobrante: Optional[float] = None

class ProcesoOut(ProcesoBase):
    id_proceso: int
    fecha: datetime
    estado: str
    leche_sobrante: Optional[float]
    produccion_kg: Optional[float]
    nombre_persona: str
    
    class Config:
        from_attributes = True
