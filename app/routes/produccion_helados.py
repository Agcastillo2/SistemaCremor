from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from datetime import datetime

from ..database import get_db
from ..models import ProduccionHelados, Persona
from ..models.rol import NombreRol
from ..schemas.produccion_helados import (
    InsumosDisponibles, ProduccionHeladosCreate, ResultadoPosible,
    FinalizarProceso, ProduccionHeladosOut
)

# Dependencia para obtener y validar al usuario autenticado con rol Jefe Helados
def get_current_persona(
    x_id_persona: int = Header(..., alias="X-Id-Persona"),
    db: Session = Depends(get_db)
) -> Persona:
    persona = db.query(Persona).filter(Persona.id_persona == x_id_persona).first()
    if not persona:
        raise HTTPException(status_code=401, detail="Usuario no autenticado")
    if persona.rol.nombre_rol != NombreRol.JEFE_HELADOS:
        raise HTTPException(status_code=403, detail="Permisos insuficientes: requiere rol Jefe Helados")
    return persona

router = APIRouter(
    prefix="/produccion",
    tags=["produccion_helados"]
)

@router.get("/insumos_disponibles", response_model=InsumosDisponibles)
def get_insumos_disponibles(
    persona: Persona = Depends(get_current_persona),
    db: Session = Depends(get_db)
):
    """Obtiene los insumos sobrantes del último proceso finalizado."""
    ultimo = (db.query(ProduccionHelados)
               .filter(ProduccionHelados.unidades_vainilla != None)
               .order_by(ProduccionHelados.id.desc())
               .first())
    if not ultimo:
        return InsumosDisponibles()
    return InsumosDisponibles(
        leche=ultimo.leche_sobrante or 0,
        vainilla=ultimo.vainilla_sobrante or 0,
        chocolate=ultimo.chocolate_sobrante or 0,
        fresa=ultimo.fresa_sobrante or 0,
        menta=ultimo.menta_sobrante or 0
    )

@router.post("/iniciar", response_model=ResultadoPosible)
def iniciar_proceso(
    data: ProduccionHeladosCreate,
    persona: Persona = Depends(get_current_persona),
    db: Session = Depends(get_db)
):
    """Inicia un nuevo proceso de producción ingresando los insumos y calcula el resultado posible."""
    # Obtener insumos disponibles previos
    prev = get_insumos_disponibles(persona, db)
    # Calcular nuevos disponibles
    disponibles = InsumosDisponibles(
        leche=prev.leche + data.leche_ingresada,
        vainilla=prev.vainilla + data.vainilla_ingresada,
        chocolate=prev.chocolate + data.chocolate_ingresada,
        fresa=prev.fresa + data.fresa_ingresada,
        menta=prev.menta + data.menta_ingresada
    )
    # Guardar registro de ingreso
    registro = ProduccionHelados(
        fecha=datetime.utcnow(),
        id_persona=persona.id_persona,
        leche_ingresada=data.leche_ingresada,
        vainilla_ingresada=data.vainilla_ingresada,
        chocolate_ingresada=data.chocolate_ingresada,
        fresa_ingresada=data.fresa_ingresada,
        menta_ingresada=data.menta_ingresada
    )
    db.add(registro)
    db.commit()
    db.refresh(registro)
    # Calcular resultado posible
    porcion_leche = disponibles.leche / 4
    max_por_leche = porcion_leche / 0.25
    unidades_vainilla = min(int(max_por_leche), int(disponibles.vainilla / 0.25))
    unidades_chocolate = min(int(max_por_leche), int(disponibles.chocolate / 0.25))
    unidades_fresa = min(int(max_por_leche), int(disponibles.fresa / 0.25))
    unidades_menta = min(int(max_por_leche), int(disponibles.menta / 0.25))
    return ResultadoPosible(
        unidades_vainilla=unidades_vainilla,
        unidades_chocolate=unidades_chocolate,
        unidades_fresa=unidades_fresa,
        unidades_menta=unidades_menta
    )

@router.post("/finalizar/{proceso_id}", response_model=ProduccionHeladosOut)
def finalizar_proceso(
    proceso_id: int,
    result: FinalizarProceso,
    persona: Persona = Depends(get_current_persona),
    db: Session = Depends(get_db)
):
    """Finaliza el proceso actualizando las unidades reales y calculando los sobrantes."""
    registro = db.query(ProduccionHelados).filter(ProduccionHelados.id == proceso_id).first()
    if not registro:
        raise HTTPException(status_code=404, detail="Proceso no encontrado")
    if registro.unidades_vainilla is not None:
        raise HTTPException(status_code=400, detail="Proceso ya finalizado")
    # Asignar unidades reales
    registro.unidades_vainilla = result.unidades_vainilla
    registro.unidades_chocolate = result.unidades_chocolate
    registro.unidades_fresa = result.unidades_fresa
    registro.unidades_menta = result.unidades_menta
    # Calcular sobrantes
    usado_leche = sum([result.unidades_vainilla, result.unidades_chocolate,
                       result.unidades_fresa, result.unidades_menta]) * 0.25
    registro.leche_sobrante = registro.leche_ingresada - usado_leche
    registro.vainilla_sobrante = registro.vainilla_ingresada - result.unidades_vainilla * 0.25
    registro.chocolate_sobrante = registro.chocolate_ingresada - result.unidades_chocolate * 0.25
    registro.fresa_sobrante = registro.fresa_ingresada - result.unidades_fresa * 0.25
    registro.menta_sobrante = registro.menta_ingresada - result.unidades_menta * 0.25
    db.commit()
    db.refresh(registro)
    return registro

@router.get("/ultimo", response_model=ProduccionHeladosOut)
def get_ultimo_proceso(
    persona: Persona = Depends(get_current_persona),
    db: Session = Depends(get_db)
):
    """Obtiene el último proceso de producción."""
    ultimo = (db.query(ProduccionHelados)
               .order_by(ProduccionHelados.id.desc())
               .first())
    if not ultimo:
        raise HTTPException(status_code=404, detail="No hay procesos registrados")
    return ultimo

@router.get("/historial", response_model=list[ProduccionHeladosOut])
def get_historial(
    persona: Persona = Depends(get_current_persona),
    db: Session = Depends(get_db)
):
    """Obtiene el historial de procesos de producción."""
    return (db.query(ProduccionHelados)
             .order_by(ProduccionHelados.fecha.desc())
             .limit(10)  # Limitamos a los últimos 10 registros
             .all())
