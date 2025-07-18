# main.py

from fastapi import FastAPI
from .database import engine
from .models.base import Base

from .routes import (
    persona_router, 
    vehiculo_router, 
    rol_router, 
    leche_router, 
    asignacion_vc_router,
    puesto_router,
    registro_es_router,
    reemplazo_router,
    hora_extra_router,
    notificacion_router,
    proceso_router,
    produccion_helados_router
)

from .models import (
    Persona, 
    Vehiculo, 
    AsignacionVehiculoConductor, 
    Rol, 
    Leche,
    Puesto,
    RegistroEntradaSalida,
    Reemplazo,
    Hora_Extra,
    Notificacion,
    Proceso,
    ProduccionHelados
)

app = FastAPI(
    title="API Sistema Cremor",
    description="API para la gestión de personal, vehículos y operaciones de Cremor.",
    version="1.0.0"
)

Base.metadata.create_all(bind=engine)

app.include_router(persona_router)
app.include_router(vehiculo_router)
app.include_router(rol_router)
app.include_router(leche_router)
app.include_router(asignacion_vc_router)
app.include_router(puesto_router)
app.include_router(registro_es_router)
app.include_router(reemplazo_router)
app.include_router(hora_extra_router)
app.include_router(notificacion_router)
app.include_router(proceso_router)
app.include_router(produccion_helados_router)  # Aseguramos que esté incluido

# Configuración CORS
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permite cualquier origen
    allow_credentials=True,
    allow_methods=["*"],  # Permite todos los métodos
    allow_headers=["*"],  # Permite todos los headers
)

@app.get("/", tags=["Root"])
def read_root():
    return {"message": "Bienvenido al sistema Cremor"}