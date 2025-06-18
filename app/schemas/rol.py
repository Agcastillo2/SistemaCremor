from enum import Enum
from datetime import date
from pydantic import BaseModel, validator
from typing import Optional

class NombreRol(str, Enum):
    JEFE_NATA = "JEFE_NATA"
    JEFE_HELADOS = "JEFE_HELADOS"
    TRABAJADOR_NATA = "TRABAJADOR_NATA"
    TRABAJADOR_HELADOS = "TRABAJADOR_HELADOS"
    SUPERVISOR = "SUPERVISOR"

    @property
    def descripcion(self):
        descripciones = {
            "JEFE_NATA": "Jefe de Nata",
            "JEFE_HELADOS": "Jefe de Helados",
            "TRABAJADOR_NATA": "Trabajador de Nata",
            "TRABAJADOR_HELADOS": "Trabajador de Helados",
            "SUPERVISOR": "Supervisor"
        }
        return descripciones[self.value]

class RolBase(BaseModel):
    nombre_rol: NombreRol
    descripcion_rol: Optional[str] = None
    departamento: Optional[str] = None
    activo: bool = True

    @validator('descripcion_rol', pre=True, always=True)
    def set_default_descripcion(cls, v, values):
        if v is None and 'nombre_rol' in values:
            return values['nombre_rol'].descripcion
        return v

class RolCreate(RolBase):
    pass

class Rol(RolBase):
    id_rol: int
    fecha_creacion: date
    nombre_completo: str

    class Config:
        from_attributes = True

    def model_dump(self, *args, **kwargs):
        data = super().model_dump(*args, **kwargs)
        if 'nombre_rol' in data:
            data['nombre_rol'] = self.nombre_rol.value  # Convert enum to string
        return data