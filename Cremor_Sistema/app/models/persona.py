from .base import Base
from enum import Enum
from datetime import date
from sqlalchemy import Column, Integer, String, Boolean, Date, Enum as EnumDB, ForeignKey
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import relationship

class EstadoCivil(str, Enum):
    SOLTERO = "SOLTERO"
    CASADO = "CASADO"
    DIVORCIADO = "DIVORCIADO"
    VIUDO = "VIUDO"
    UNION_LIBRE = "UNION_LIBRE"

class Disponibilidad(str, Enum):
    DISPONIBLE = "DISPONIBLE"
    VACACIONES = "VACACIONES"
    INACTIVO = "INACTIVO"
    PERMISO_MEDICO = "PERMISO_MEDICO"

class TipoLicencia(str, Enum):
    B = "B"
    C = "C"
    D = "D"
    E = "E"
    F = "F"
    G = "G"
    A1 = "A1"
    A2 = "A2"
    NINGUNA = "NINGUNA"

class TipoSangre(str, Enum):
    A_POSITIVO = "A+"
    A_NEGATIVO = "A-"
    B_POSITIVO = "B+"
    B_NEGATIVO = "B-"
    AB_POSITIVO = "AB+"
    AB_NEGATIVO = "AB-"
    O_POSITIVO = "O+"
    O_NEGATIVO = "O-"

class Persona(Base):
    __tablename__ = "persona"

    id_persona = Column(Integer, primary_key=True, index=True)
    numero_identificacion = Column(String(10), unique=True, nullable=False)
    nombres = Column(String(50), nullable=False)
    apellidos = Column(String(50), nullable=False)
    fecha_nacimiento = Column(Date, nullable=False)
    numero_hijos = Column(Integer, nullable=False, default=0)
    tipo_sangre = Column(EnumDB(TipoSangre), nullable=False)
    genero = Column(Boolean, nullable=False)  # True: masculino, False: femenino
    direccion = Column(String(100), nullable=False)
    telefono = Column(String(10), nullable=False)
    correo = Column(String(50), nullable=False, unique=True)
    disponibilidad = Column(EnumDB(Disponibilidad), nullable=False)
    estado_civil = Column(EnumDB(EstadoCivil), nullable=False)
    tipo_licencia = Column(EnumDB(TipoLicencia), default=TipoLicencia.NINGUNA)
    vencimiento_licencia = Column(Date)
    antiguedad_conduccion = Column(Integer, default=0)
    hashed_password = Column(String)  # Campo para la contraseña hasheada
    id_rol = Column(Integer, ForeignKey('rol.id_rol'))  # Nueva columna para la relación con Rol
    fecha_registro = Column(Date, nullable=False, default=date.today)  # Agregado campo fecha_registro
    
    # Relación con Rol
    rol = relationship("Rol", back_populates="personas")
    
    # Otras relaciones existentes
    asignaciones_vehiculos = relationship(
        "AsignacionVehiculoConductor", 
        back_populates="persona",
        lazy="dynamic"
    )

    @property
    def nombre_completo(self):
        return f"{self.nombres} {self.apellidos}"