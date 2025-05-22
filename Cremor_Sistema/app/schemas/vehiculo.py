from enum import Enum
from datetime import date
from pydantic import BaseModel, constr,StringConstraints, validator
from typing import Optional,Annotated

class Marca(str, Enum):
    # Gama Media
    TOYOTA = "TOYOTA"
    HYUNDAI = "HYUNDAI"
    KIA = "KIA"
    CHEVROLET = "CHEVROLET"
    MAZDA = "MAZDA"
    NISSAN = "NISSAN"
    VOLKSWAGEN = "VOLKSWAGEN"
    SUZUKI = "SUZUKI"
    MITSUBISHI = "MITSUBISHI"
    FORD = "FORD"
    RENAULT = "RENAULT"
    HONDA = "HONDA"
    CHERY = "CHERY"
    JAC = "JAC"
    GREAT_WALL = "GREAT_WALL"
    
    # Gama Baja
    BYD = "BYD"
    MG = "MG"
    GEELY = "GEELY"
    CHANGAN = "CHANGAN"
    DODGE = "DODGE"
    FIAT = "FIAT"
    PEUGEOT = "PEUGEOT"
    CITROEN = "CITROEN"
    HAVAL = "HAVAL"
    ZOTYE = "ZOTYE"
    
    # Marcas comerciales/pesados
    HINO = "HINO"
    ISUZU = "ISUZU"
    SCANIA = "SCANIA"
    INTERNATIONAL = "INTERNATIONAL"
    FREIGHTLINER = "FREIGHTLINER"
    KENWORTH = "KENWORTH"
    PETERBILT = "PETERBILT"
    MACK = "MACK"
    VOLVO_TRUCKS = "VOLVO_TRUCKS"
    YUTONG = "YUTONG"
    
    # Opción genérica
    OTRO = "OTRO"

class TipoVehiculo(str, Enum):
    SEDAN = "SEDAN"
    CAMIONETA = "CAMIONETA"
    CAMION = "CAMION"
    AUTOBUS = "AUTOBUS"
    FURGONETA = "FURGONETA"
    OTRO = "OTRO"

class TipoGasolina(str, Enum):
    REGULAR = "REGULAR"
    EXTRA = "EXTRA"
    DIESEL = "DIESEL"
    ELECTRICO = "ELECTRICO"
    HIBRIDO = "HIBRIDO"
    GAS = "GAS"
    PREMIUM = "PREMIUM"
    ECOPAIS = "ECOPAIS"
    ECO_PLUS = "ECO_PLUS"
    

# Definiciones de tipos con restricciones
PlacaStr = Annotated[str, StringConstraints(max_length=10, strip_whitespace=True)]
ModeloStr = Annotated[str, StringConstraints(max_length=50, strip_whitespace=True)]
ColorStr = Annotated[str, StringConstraints(strip_whitespace=True)]

class VehiculoBase(BaseModel):
    placa: PlacaStr
    marca: Marca
    modelo: ModeloStr
    anio: int
    color: ColorStr
    tipo_vehiculo: TipoVehiculo
    capacidad_carga: Optional[float] = None
    tipo_gasolina: TipoGasolina
    fecha_ultimo_mantenimiento: Optional[date] = None
    estado: bool = True
    kilometraje: int = 0

    @validator('anio')
    def validar_anio(cls, v):
        current_year = date.today().year
        if v < 1900:
            raise ValueError("El año debe ser mayor a 1900")
        if v > current_year + 1:
            raise ValueError("El año no puede ser mayor al año actual + 1")
        return v

    @validator('capacidad_carga')
    def validar_capacidad_carga(cls, v):
        if v is not None and v < 0:
            raise ValueError("La capacidad de carga no puede ser negativa")
        return v

    @validator('kilometraje')
    def validar_kilometraje(cls, v):
        if v < 0:
            raise ValueError("El kilometraje no puede ser negativo")
        return v

class VehiculoCreate(VehiculoBase):
    pass

class Vehiculo(VehiculoBase):
    id_vehiculo: int
    info_basica: str

    class Config:
        from_attributes = True