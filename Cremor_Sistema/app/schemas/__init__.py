# app/schemas/__init__.py

from .persona import PersonaBase, PersonaCreate, Persona
from .vehiculo import VehiculoBase, VehiculoCreate, Vehiculo
from .rol import RolBase, RolCreate, Rol
from .leche import LecheBase, LecheCreate, Leche
from .asignacion_vc import AsignacionVCBase, AsignacionVCCreate, AsignacionVC
from .persona_auth import LoginCredentials
from .puesto import PuestoBase, PuestoCreate, PuestoUpdate, Puesto
from .registro_entrada_salida import RegistroEntradaCreate, RegistroSalidaUpdate, RegistroEntradaSalida
from .reemplazo import ReemplazoBase, ReemplazoCreate, Reemplazo
from .hora_extra import HoraExtraBase, HoraExtraCreate, HoraExtra
from .notificacion import NotificacionBase, NotificacionCreate, Notificacion # <-- NUEVO

__all__ = [
    "PersonaBase", "PersonaCreate", "Persona",
    "VehiculoBase", "VehiculoCreate", "Vehiculo",
    "RolBase", "RolCreate", "Rol",
    "LecheBase", "LecheCreate", "Leche",
    "AsignacionVCBase", "AsignacionVCCreate", "AsignacionVC",
    "LoginCredentials",
    "PuestoBase", "PuestoCreate", "PuestoUpdate", "Puesto",
    "RegistroEntradaCreate", "RegistroSalidaUpdate", "RegistroEntradaSalida",
    "ReemplazoBase", "ReemplazoCreate", "Reemplazo",
    "HoraExtraBase", "HoraExtraCreate", "HoraExtra",
    "NotificacionBase", "NotificacionCreate", "Notificacion" # <-- NUEVO
]