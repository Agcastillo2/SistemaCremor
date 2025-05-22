from fastapi import FastAPI
from .database import engine
from .models.base import Base  # Importa Base desde el archivo central
from .routes import persona_router, vehiculo_router, rol_router, leche_router, asignacion_vc_router

# Importa todos los modelos para que SQLAlchemy los registre
from .models import Persona, Vehiculo, AsignacionVehiculoConductor, Rol, Leche

app = FastAPI()

# Crea todas las tablas
Base.metadata.create_all(bind=engine)

# Configura routers
app.include_router(persona_router)
app.include_router(vehiculo_router)
app.include_router(rol_router)
app.include_router(leche_router)
app.include_router(asignacion_vc_router)

@app.get("/")
def read_root():
    return {"message": "Bienvenido al sistema Cremor"}