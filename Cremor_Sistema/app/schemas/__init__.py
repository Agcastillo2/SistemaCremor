from .persona import PersonaBase, PersonaCreate, Persona
from .vehiculo import VehiculoBase, VehiculoCreate, Vehiculo
from .rol import RolBase, RolCreate, Rol
from .leche import LecheBase,LecheCreate,Leche
from .asignacion_vc import AsignacionVCBase,AsignacionVCCreate,AsignacionVC

__all__ = [
    "PersonaBase", "PersonaCreate", "Persona",
    "VehiculoBase", "VehiculoCreate", "Vehiculo",
    "RolBase", "RolCreate", "Rol",
    "LecheBase", "LecheCreate", "Leche",
    "AsignacionVCBase", "AsignacionVCCreate", "AsignacionVC"
]