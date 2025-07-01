# app/routes/__init__.py

from .persona import router as persona_router
from .vehiculo import router as vehiculo_router
from .rol import router as rol_router
from .leche import router as leche_router
from .asignacion_vc import router as asignacion_vc_router
from .puesto import router as puesto_router
from .registro_entrada_salida import router as registro_es_router
from .reemplazo import router as reemplazo_router
from .hora_extra import router as hora_extra_router
from .notificacion import router as notificacion_router
from .proceso import router as proceso_router
from .produccion_helados import router as produccion_helados_router

__all__ = [
    "persona_router", 
    "vehiculo_router", 
    "rol_router",
    "leche_router",
    "asignacion_vc_router",
    "puesto_router",
    "registro_es_router",
    "reemplazo_router",
    "hora_extra_router",
    "notificacion_router",
    "proceso_router",
    "produccion_helados_router"
]