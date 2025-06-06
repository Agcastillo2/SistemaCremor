from pydantic import BaseModel
from datetime import datetime
from typing import Optional
from .persona import Persona
from .rol import Rol
from .puesto import Puesto
from ..models.registro_entrada_salida import EstadoAsistencia, TipoTurno

class RegistroEntradaSalidaBase(BaseModel):
    id_persona: int
    id_rol: int
    id_puesto: int
    turno: TipoTurno
    observaciones: Optional[str] = None

class RegistroEntradaCreate(RegistroEntradaSalidaBase):
    pass

class RegistroSalidaUpdate(BaseModel):
    observaciones: Optional[str] = None

class RegistroEntradaSalida(RegistroEntradaSalidaBase):
    id_registro: int
    fecha_hora_entrada: datetime
    fecha_hora_salida: Optional[datetime] = None
    estado: EstadoAsistencia
    persona: Persona
    rol: Rol
    puesto: Puesto

    class Config:
        from_attributes = True