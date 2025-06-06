# app/schemas/puesto.py

from pydantic import BaseModel
from typing import Optional

# --- Esquema Base ---
# Contiene los campos comunes que se usan tanto para la creación como para la lectura.
class PuestoBase(BaseModel):
    descripcion: str
    activo: bool = True

# --- Esquema de Creación ---
# Usado para recibir datos al crear un nuevo puesto.
class PuestoCreate(PuestoBase):
    pass

# --- Esquema de Actualización ---
# Permite actualizar solo algunos campos, haciéndolos todos opcionales.
class PuestoUpdate(BaseModel):
    descripcion: Optional[str] = None
    activo: Optional[bool] = None

# --- Esquema de Lectura ---
# El modelo que se devolverá en la respuesta de la API. Incluye el ID.
class Puesto(PuestoBase):
    id_puesto: int

    class Config:
        from_attributes = True