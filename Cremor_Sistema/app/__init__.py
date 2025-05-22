# Este archivo puede estar vacío o puedes colocar inicializaciones
# Para que FastAPI reconozca los routers, puedes importarlos aquí

from .routes import persona
from .routes import vehiculo
from .routes import rol
from .routes import leche
from .routes import asignacion_vc
from .main import app

__all__ = ["app", "persona","vehiculo","rol","leche","asignacion_vc"]