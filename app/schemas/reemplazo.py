# En tu archivo de esquemas (ej: app/schemas/reemplazo.py)
from pydantic import BaseModel, model_validator
from datetime import date
from typing import Optional

# Importamos los Enums del modelo para reutilizarlos
from ..models.reemplazo import TipoReemplazo, EstadoReemplazo 
# Importamos un esquema de Persona para las respuestas
from .persona import Persona as PersonaSchema

# Esquema base con todos los campos posibles
class ReemplazoBase(BaseModel):
    tipo_reemplazo: TipoReemplazo
    id_persona_reemplazada: int
    fecha_inicio: date
    fecha_fin: date
    motivo: str
    estado: EstadoReemplazo = EstadoReemplazo.ACTIVO

    # Campos condicionales (todos opcionales al principio)
    id_persona_reemplazo: Optional[int] = None
    nombre_externo: Optional[str] = None
    contacto_externo: Optional[str] = None
    documento_externo: Optional[str] = None


# Esquema para la creación de un Reemplazo (con validación)
class ReemplazoCreate(ReemplazoBase):
    
    @model_validator(mode='after')
    def check_reemplazo_type(self) -> 'ReemplazoCreate':
        if self.tipo_reemplazo == TipoReemplazo.INTERNO:
            if not self.id_persona_reemplazo:
                raise ValueError("Para reemplazos internos, 'id_persona_reemplazo' es obligatorio.")
            if self.nombre_externo or self.contacto_externo:
                raise ValueError("Campos externos no deben ser proporcionados para reemplazos internos.")
        
        elif self.tipo_reemplazo == TipoReemplazo.EXTERNO:
            if not self.nombre_externo or not self.contacto_externo:
                raise ValueError("Para reemplazos externos, 'nombre_externo' y 'contacto_externo' son obligatorios.")
            if self.id_persona_reemplazo:
                raise ValueError("'id_persona_reemplazo' no debe ser proporcionado para reemplazos externos.")
        
        return self

# Esquema para las respuestas de la API (lo que se devuelve al cliente)
class Reemplazo(ReemplazoBase):
    id_reemplazo: int
    
    # Incluimos los objetos completos de Persona para dar más contexto
    persona_reemplazada: PersonaSchema
    persona_reemplazo: Optional[PersonaSchema] = None

    class Config:
        from_attributes = True # Equivalente a orm_mode = True en Pydantic v1