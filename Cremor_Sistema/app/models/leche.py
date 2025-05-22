from datetime import date
from sqlalchemy import Column, Integer, String, Float, Boolean, Date
from sqlalchemy.orm import declarative_base
from sqlalchemy import UniqueConstraint
from .base import Base

class Leche(Base):
    __tablename__ = "leche"
    __table_args__ = (
        UniqueConstraint('fecha', 'proveedor', name='uk_leche_fecha_proveedor'),
    )

    id_leche = Column(Integer, primary_key=True, index=True)
    fecha = Column(Date, nullable=False)
    proveedor = Column(String(50), nullable=False)
    cantidad_litros = Column(Integer, nullable=False)
    temperatura = Column(Float, nullable=False)  # Temperatura en °C
    grasa = Column(Float, nullable=False)  # Grasa en %
    solidos_sng = Column(Float, nullable=False)  # Sólidos SNG en %
    densidad = Column(Float, nullable=False)  # Densidad en g/l
    proteina = Column(Float, nullable=False)  # Proteína en %
    lactosa = Column(Float, nullable=False)  # Lactosa en %
    sal = Column(Float, nullable=False)  # Sal en mg
    agua_anadida = Column(Float, nullable=False)  # Agua añadida en %
    acidez = Column(Float, nullable=False)  # Acidez en %
    punto_congelacion = Column(Float, nullable=False)  # Punto de congelación
    ph = Column(Float, nullable=False)  # pH
    observaciones = Column(String(255))
    estado = Column(Boolean, nullable=False, default=True)
    fecha_registro = Column(Date, nullable=False, default=date.today())

    @property
    def info_basica(self):
        return (f"Proveedor: {self.proveedor}, "
                f"Fecha: {self.fecha}, "
                f"Cantidad: {self.cantidad_litros} litros, "
                f"Temperatura: {self.temperatura}°C, "
                f"Grasa: {self.grasa}%, "
                f"Estado: {'Activo' if self.estado else 'Inactivo'}")