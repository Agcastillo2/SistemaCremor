from .base import Base
from enum import Enum
from datetime import date
from sqlalchemy import Column, Integer, String, Float, Boolean, Date, Enum as EnumDB
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy import event
from datetime import datetime

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

class Vehiculo(Base):
    __tablename__ = "vehiculo"
    
    id_vehiculo = Column(Integer, primary_key=True, index=True)
    placa = Column(String(10), nullable=False, unique=True)
    marca = Column(EnumDB(Marca), nullable=False)
    modelo = Column(String(50), nullable=False)
    anio = Column(Integer, nullable=False)
    color = Column(String(50), nullable=False)
    tipo_vehiculo = Column(EnumDB(TipoVehiculo), nullable=False)
    capacidad_carga = Column(Float)
    tipo_gasolina = Column(EnumDB(TipoGasolina), nullable=False)
    fecha_ultimo_mantenimiento = Column(Date)
    estado = Column(Boolean, nullable=False, default=True)
    kilometraje = Column(Integer, nullable=False, default=0)
    asignaciones_conductores = relationship(
        "AsignacionVehiculoConductor", 
        back_populates="vehiculo",
        lazy="dynamic"
    )

    @property
    def info_basica(self):
        return f"{self.marca} {self.modelo} ({self.anio}) - {self.placa}"

# Validación para el año
@event.listens_for(Vehiculo, 'before_insert')
@event.listens_for(Vehiculo, 'before_update')
def validar_anio(mapper, connection, target):
    current_year = datetime.now().year
    if target.anio > current_year + 1:
        raise ValueError("El año no puede ser mayor al año actual + 1")