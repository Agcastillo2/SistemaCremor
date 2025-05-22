from .persona import router as persona_router
from .vehiculo import router as vehiculo_router
from .rol import router as rol_router
from .leche import router as leche_router
from .asignacion_vc import router as asignacion_vc_router

__all__ = ["persona_router", "vehiculo_router", "rol_router","leche_router","asignacion_vc_router"]