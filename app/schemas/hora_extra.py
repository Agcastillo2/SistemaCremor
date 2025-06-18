# En app/schemas/hora_extra.py

from pydantic import BaseModel, model_validator
from datetime import date, datetime
from typing import Optional

# Importamos los Enums y otros esquemas necesarios
from ..models.hora_extra import TipoRegistroHoraExtra, TipoPagoDia, EstadoHoraExtra
from .persona import Persona as PersonaSchema
from .puesto import Puesto as PuestoSchema

# Esquema base con todos los campos opcionales
class HoraExtraBase(BaseModel):
    id_persona: int
    id_puesto: int
    tipo_registro: TipoRegistroHoraExtra
    motivo: str
    estado: EstadoHoraExtra = EstadoHoraExtra.PENDIENTE

    # Campos condicionales
    fecha_dia: Optional[date] = None
    tipo_pago_dia: Optional[TipoPagoDia] = None
    cantidad_dias: Optional[int] = None
    fecha_hora_inicio: Optional[datetime] = None
    fecha_hora_fin: Optional[datetime] = None

# Esquema para la creación (con validación estricta)
class HoraExtraCreate(HoraExtraBase):
    
    @model_validator(mode='after')
    def check_registro_type(self) -> 'HoraExtraCreate':
        # Lógica para registro por DÍA
        if self.tipo_registro == TipoRegistroHoraExtra.DIA:
            if not all([self.fecha_dia, self.tipo_pago_dia, self.cantidad_dias]):
                raise ValueError("Para tipo 'DIA', se requieren 'fecha_dia', 'tipo_pago_dia' y 'cantidad_dias'.")
            if self.fecha_hora_inicio or self.fecha_hora_fin:
                raise ValueError("Campos de hora no deben ser proporcionados para tipo 'DIA'.")
        
        # Lógica para registro por HORA
        elif self.tipo_registro == TipoRegistroHoraExtra.HORA:
            if not all([self.fecha_hora_inicio, self.fecha_hora_fin]):
                raise ValueError("Para tipo 'HORA', se requieren 'fecha_hora_inicio' y 'fecha_hora_fin'.")
            if any([self.fecha_dia, self.tipo_pago_dia, self.cantidad_dias]):
                raise ValueError("Campos de día no deben ser proporcionados para tipo 'HORA'.")
        
        return self

# Esquema para las respuestas de la API
class HoraExtra(HoraExtraBase):
    id_hora_extra: int
    horas_calculadas: Optional[float] = None
    
    # Incluimos los objetos completos para dar más contexto
    persona: PersonaSchema
    puesto: PuestoSchema

    class Config:
        from_attributes = True