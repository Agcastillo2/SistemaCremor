from typing import Optional
from ..exceptions.proceso_exceptions import (
    DatosProcesoInvalidosError,
    OrdenProcesoInvalidoError
)

class ProcesoValidator:
    """Clase para validar datos de procesos"""
    
    @staticmethod
    def validar_secuencia_procesos(proceso_x: int, proceso_y: int, ultimo_proceso: Optional[dict] = None) -> bool:
        """
        Valida la secuencia de procesos X e Y
        
        Args:
            proceso_x: Número del proceso X
            proceso_y: Número del proceso Y
            ultimo_proceso: Diccionario con información del último proceso
            
        Returns:
            bool: True si la secuencia es válida
            
        Raises:
            OrdenProcesoInvalidoError: Si la secuencia no es válida
            DatosProcesoInvalidosError: Si los datos son inválidos
        """
        # Validar rango de procesos
        if not (1 <= proceso_x <= 6 and 1 <= proceso_y <= 6):
            raise DatosProcesoInvalidosError("Los procesos deben estar entre 1 y 6")
            
        # Si es el primer proceso, debe ser (1,1)
        if ultimo_proceso is None:
            if proceso_x != 1 or proceso_y != 1:
                raise OrdenProcesoInvalidoError("El primer proceso debe ser X=1 y Y=1")
            return True
            
        # Validar secuencia con proceso anterior
        if ultimo_proceso["estado"] == "Finalizado":
            proc_x_anterior = int(ultimo_proceso["proceso_x"])
            proc_y_anterior = int(ultimo_proceso["proceso_y"])
            
            siguiente_x = proc_x_anterior + 1 if proc_x_anterior < 6 else 1
            siguiente_y = proc_y_anterior + 1 if proc_y_anterior < 6 else 1
            
            if proceso_x != siguiente_x or proceso_y != siguiente_y:
                raise OrdenProcesoInvalidoError(
                    f"Secuencia inválida. Después de X={proc_x_anterior}, Y={proc_y_anterior} "
                    f"debe seguir X={siguiente_x}, Y={siguiente_y}"
                )
                
        return True
    
    @staticmethod
    def validar_datos_proceso(leche_ingresada: Optional[float] = None,
                            produccion_kg: Optional[float] = None,
                            leche_sobrante: Optional[float] = None) -> bool:
        """
        Valida los datos numéricos del proceso
        
        Args:
            leche_ingresada: Cantidad de leche ingresada
            produccion_kg: Cantidad de producción en kg
            leche_sobrante: Cantidad de leche sobrante
            
        Returns:
            bool: True si los datos son válidos
            
        Raises:
            DatosProcesoInvalidosError: Si los datos son inválidos
        """
        if leche_ingresada is not None and leche_ingresada < 0:
            raise DatosProcesoInvalidosError("La leche ingresada no puede ser negativa")
            
        if produccion_kg is not None and produccion_kg < 0:
            raise DatosProcesoInvalidosError("La producción no puede ser negativa")
            
        if leche_sobrante is not None and leche_sobrante < 0:
            raise DatosProcesoInvalidosError("La leche sobrante no puede ser negativa")
            
        if leche_ingresada is not None and leche_sobrante is not None:
            if leche_sobrante > leche_ingresada:
                raise DatosProcesoInvalidosError("La leche sobrante no puede ser mayor a la ingresada")
                
        return True
