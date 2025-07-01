from datetime import datetime
from typing import Optional
from sqlalchemy.orm import Session
from ..models.proceso import Proceso
from ..models.persona import Persona
from ..exceptions.proceso_exceptions import (
    ProcesoNoEncontradoError,
    ProcesoEnProgresoError,
    PermisoProcesoError
)
from ..validators.proceso_validator import ProcesoValidator

class ProcesoBase:
    """Clase base para gestionar procesos"""
    
    def __init__(self, db: Session):
        self.db = db
        self.validator = ProcesoValidator()
    
    def obtener_proceso(self, id_proceso: int) -> Proceso:
        """
        Obtiene un proceso por su ID
        
        Args:
            id_proceso: ID del proceso a buscar
            
        Returns:
            Proceso: Instancia del proceso encontrado
            
        Raises:
            ProcesoNoEncontradoError: Si no se encuentra el proceso
        """
        proceso = self.db.query(Proceso).filter(Proceso.id_proceso == id_proceso).first()
        if not proceso:
            raise ProcesoNoEncontradoError(f"No se encontró el proceso con ID {id_proceso}")
        return proceso
    
    def verificar_proceso_en_progreso(self) -> Optional[Proceso]:
        """
        Verifica si hay un proceso en progreso
        
        Returns:
            Optional[Proceso]: Proceso en progreso o None
        """
        return self.db.query(Proceso).filter(Proceso.estado == "En progreso").first()
    
    def crear_proceso(self, 
                     id_persona: int,
                     proceso_x: int,
                     proceso_y: int,
                     leche_ingresada: float) -> Proceso:
        """
        Crea un nuevo proceso
        
        Args:
            id_persona: ID de la persona que crea el proceso
            proceso_x: Número del proceso X
            proceso_y: Número del proceso Y
            leche_ingresada: Cantidad de leche ingresada
            
        Returns:
            Proceso: Instancia del proceso creado
            
        Raises:
            ProcesoEnProgresoError: Si hay un proceso en progreso
            DatosProcesoInvalidosError: Si los datos son inválidos
        """
        # Verificar proceso en progreso
        if self.verificar_proceso_en_progreso():
            raise ProcesoEnProgresoError("Ya existe un proceso en progreso")
            
        # Validar datos
        self.validator.validar_datos_proceso(leche_ingresada=leche_ingresada)
        
        # Obtener último proceso para validar secuencia
        ultimo_proceso = self.db.query(Proceso).order_by(Proceso.fecha.desc()).first()
        self.validator.validar_secuencia_procesos(
            proceso_x, 
            proceso_y,
            ultimo_proceso.__dict__ if ultimo_proceso else None
        )
        
        # Crear nuevo proceso
        nuevo_proceso = Proceso(
            fecha=datetime.now(),
            proceso_x=proceso_x,
            proceso_y=proceso_y,
            estado="En progreso",
            leche_ingresada=leche_ingresada,
            id_persona=id_persona
        )
        
        self.db.add(nuevo_proceso)
        self.db.commit()
        self.db.refresh(nuevo_proceso)
        
        return nuevo_proceso
    
    def finalizar_proceso(self,
                         id_proceso: int,
                         id_persona: int,
                         produccion_kg: float,
                         leche_sobrante: Optional[float] = None) -> Proceso:
        """
        Finaliza un proceso existente
        
        Args:
            id_proceso: ID del proceso a finalizar
            id_persona: ID de la persona que finaliza el proceso
            produccion_kg: Cantidad producida en kg
            leche_sobrante: Cantidad de leche sobrante
            
        Returns:
            Proceso: Instancia del proceso finalizado
            
        Raises:
            PermisoProcesoError: Si la persona no tiene permisos
            DatosProcesoInvalidosError: Si los datos son inválidos
        """
        proceso = self.obtener_proceso(id_proceso)
        
        # Verificar permisos
        if proceso.id_persona != id_persona:
            raise PermisoProcesoError(
                "Solo el jefe que inició el proceso puede finalizarlo"
            )
            
        # Validar datos
        self.validator.validar_datos_proceso(
            leche_ingresada=proceso.leche_ingresada,
            produccion_kg=produccion_kg,
            leche_sobrante=leche_sobrante
        )
        
        # Actualizar proceso
        proceso.estado = "Finalizado"
        proceso.produccion_kg = produccion_kg
        if leche_sobrante is not None:
            proceso.leche_sobrante = leche_sobrante
            
        self.db.commit()
        self.db.refresh(proceso)
        
        return proceso
