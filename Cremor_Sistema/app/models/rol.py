from enum import Enum
from datetime import date
from sqlalchemy import Column, Integer, String, Boolean, Date, Enum as EnumDB
from sqlalchemy.orm import declarative_base
from .base import Base

class NombreRol(str, Enum):
    JEFE_NATA = "JEFE_NATA"
    JEFE_HELADOS = "JEFE_HELADOS"
    TRABAJADOR_NATA = "TRABAJADOR_NATA"
    TRABAJADOR_HELADOS = "TRABAJADOR_HELADOS"
    SUPERVISOR = "SUPERVISOR"

    @property
    def descripcion(self):
        descripciones = {
            "JEFE_NATA": "Jefe de Nata",
            "JEFE_HELADOS": "Jefe de Helados",
            "TRABAJADOR_NATA": "Trabajador de Nata",
            "TRABAJADOR_HELADOS": "Trabajador de Helados",
            "SUPERVISOR": "Supervisor"
        }
        return descripciones[self.value]

    @classmethod
    def from_descripcion(cls, descripcion: str):
        for nombre in cls:
            if nombre.descripcion.lower() == descripcion.lower():
                return nombre
        raise ValueError(f"Descripción de rol inválida: {descripcion}")

class Rol(Base):
    __tablename__ = "rol"

    id_rol = Column(Integer, primary_key=True, index=True)
    nombre_rol = Column(EnumDB(NombreRol), nullable=False)
    descripcion_rol = Column(String(100))
    departamento = Column(String(50))
    fecha_creacion = Column(Date, nullable=False, default=date.today())
    activo = Column(Boolean, nullable=False, default=True)

    @property
    def nombre_completo(self):
        return f"{self.nombre_rol.descripcion} - {self.departamento or 'Sin departamento'}"