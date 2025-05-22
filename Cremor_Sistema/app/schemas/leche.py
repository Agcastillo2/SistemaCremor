from datetime import date
from pydantic import BaseModel,StringConstraints, validator, constr
from typing import Optional,Annotated

ProveedorStr = Annotated[str, StringConstraints(max_length=50, strip_whitespace=True)]

class LecheBase(BaseModel):
    fecha: date
    proveedor: ProveedorStr
    cantidad_litros: int
    temperatura: float  # °C
    grasa: float  # %
    solidos_sng: float  # %
    densidad: float  # g/l
    proteina: float  # %
    lactosa: float  # %
    sal: float  # mg
    agua_anadida: float  # %
    acidez: float  # %
    punto_congelacion: float
    ph: float
    observaciones: Optional[str] = None
    estado: bool = True

    @validator('cantidad_litros')
    def validate_cantidad_litros(cls, v):
        if v <= 0:
            raise ValueError("La cantidad de leche debe ser mayor a cero")
        return v

    @validator('temperatura', 'grasa', 'solidos_sng', 'densidad', 
               'proteina', 'lactosa', 'sal', 'agua_anadida', 
               'acidez', 'punto_congelacion', 'ph')
    def validate_not_none(cls, v):
        if v is None:
            raise ValueError("Este campo es obligatorio")
        return v

class LecheCreate(LecheBase):
    pass

class Leche(LecheBase):
    id_leche: int
    fecha_registro: date
    info_basica: str

    class Config:
        from_attributes = True