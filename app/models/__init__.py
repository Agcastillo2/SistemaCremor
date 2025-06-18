# app/models/__init__.py

from .base import Base
from .persona import Persona, EstadoCivil, Disponibilidad, TipoLicencia, TipoSangre
from .vehiculo import Vehiculo, TipoVehiculo, TipoGasolina, Marca
from .asignacion_vc import AsignacionVehiculoConductor, MotivoAsignacion
from .rol import Rol, NombreRol
from .leche import Leche
from .puesto import Puesto
from .registro_entrada_salida import RegistroEntradaSalida, EstadoAsistencia, TipoTurno
from .reemplazo import Reemplazo, TipoReemplazo, EstadoReemplazo
from .hora_extra import Hora_Extra, TipoRegistroHoraExtra, TipoPagoDia, EstadoHoraExtra
from .notificacion import Notificacion, PrioridadNotificacion, EstadoNotificacion, MotivoNotificacion
from .proceso import Proceso

__all__ = [
    "Base",
    "Persona", "EstadoCivil", "Disponibilidad", "TipoLicencia", "TipoSangre",
    "Vehiculo", "TipoVehiculo", "TipoGasolina", "Marca",
    "AsignacionVehiculoConductor", "MotivoAsignacion",
    "Rol", "NombreRol",
    "Leche",
    "Puesto",
    "RegistroEntradaSalida", "EstadoAsistencia", "TipoTurno",
    "Reemplazo", "TipoReemplazo", "EstadoReemplazo",
    "Hora_Extra", "TipoRegistroHoraExtra", "TipoPagoDia", "EstadoHoraExtra",
    "Notificacion", "PrioridadNotificacion", "EstadoNotificacion", "MotivoNotificacion",
    "Proceso"
]