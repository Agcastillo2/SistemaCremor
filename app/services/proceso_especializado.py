from sqlalchemy.orm import Session
from .proceso_base import ProcesoBase

class ProcesoNata(ProcesoBase):
    """Clase para gestionar procesos específicos de nata"""
    
    def __init__(self, db: Session):
        super().__init__(db)
        
    def validar_temperatura_pasteurizacion(self, temperatura: float) -> bool:
        """
        Valida la temperatura de pasteurización específica para nata
        
        Args:
            temperatura: Temperatura en grados celsius
            
        Returns:
            bool: True si la temperatura es válida
        """
        # Temperatura óptima para nata: 72-75°C
        return 72 <= temperatura <= 75
        
    def validar_tiempo_pasteurizacion(self, tiempo_minutos: int) -> bool:
        """
        Valida el tiempo de pasteurización específico para nata
        
        Args:
            tiempo_minutos: Tiempo en minutos
            
        Returns:
            bool: True si el tiempo es válido
        """
        # Tiempo óptimo para nata: 15-20 minutos
        return 15 <= tiempo_minutos <= 20
        
    def calcular_rendimiento_nata(self, leche_ingresada: float, nata_producida: float) -> float:
        """
        Calcula el rendimiento del proceso de nata
        
        Args:
            leche_ingresada: Litros de leche ingresada
            nata_producida: Kilogramos de nata producida
            
        Returns:
            float: Porcentaje de rendimiento
        """
        return (nata_producida / leche_ingresada) * 100
        
class ProcesoHelados(ProcesoBase):
    """Clase para gestionar procesos específicos de helados"""
    
    def __init__(self, db: Session):
        super().__init__(db)
        
    def validar_temperatura_congelacion(self, temperatura: float) -> bool:
        """
        Valida la temperatura de congelación específica para helados
        
        Args:
            temperatura: Temperatura en grados celsius
            
        Returns:
            bool: True si la temperatura es válida
        """
        # Temperatura óptima para helados: -18 a -22°C
        return -22 <= temperatura <= -18
        
    def validar_tiempo_batido(self, tiempo_minutos: int) -> bool:
        """
        Valida el tiempo de batido específico para helados
        
        Args:
            tiempo_minutos: Tiempo en minutos
            
        Returns:
            bool: True si el tiempo es válido
        """
        # Tiempo óptimo de batido: 8-12 minutos
        return 8 <= tiempo_minutos <= 12
        
    def calcular_rendimiento_helado(self, mezcla_base: float, helado_producido: float) -> float:
        """
        Calcula el rendimiento del proceso de helados
        
        Args:
            mezcla_base: Litros de mezcla base
            helado_producido: Kilogramos de helado producido
            
        Returns:
            float: Porcentaje de rendimiento
        """
        return (helado_producido / mezcla_base) * 100
