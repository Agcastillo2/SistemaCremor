# Importa todos tus modelos aquí para facilitar su acceso
from .base import Base
from .persona import Persona, EstadoCivil, Disponibilidad, TipoLicencia, TipoSangre
from .vehiculo import Vehiculo, TipoVehiculo, TipoGasolina, Marca
from .asignacion_vc import AsignacionVehiculoConductor, MotivoAsignacion
from .rol import Rol, NombreRol
from .leche import Leche

__all__ = ["Persona","Vehiculo","Rol","Leche","AsignacionVehiculoConductor"]