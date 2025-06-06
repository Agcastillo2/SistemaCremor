# app/__init__.py

from .main import app

from .routes import (
    persona, 
    vehiculo, 
    rol, 
    leche, 
    asignacion_vc, 
    puesto, 
    registro_entrada_salida,
    reemplazo,
    hora_extra,
    notificacion # <-- NUEVO
)

__all__ = [
    "app", 
    "persona", 
    "vehiculo", 
    "rol", 
    "leche", 
    "asignacion_vc", 
    "puesto", 
    "registro_entrada_salida",
    "reemplazo",
    "hora_extra",
    "notificacion" # <-- NUEVO
]