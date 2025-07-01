# app/models/persona.py

from .base import Base
from enum import Enum
from datetime import date
from sqlalchemy import Column, Integer, String, Boolean, Date, Enum as EnumDB, ForeignKey
from sqlalchemy.orm import relationship

# --- Clases Enum ---
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

# --- Modelo Principal de Persona ---
class Persona(Base):
    __tablename__ = "persona"

    # --- Columnas de la Tabla ---
    id_persona = Column(Integer, primary_key=True, index=True)
    numero_identificacion = Column(String(10), unique=True, nullable=False)
    nombres = Column(String(50), nullable=False)
    apellidos = Column(String(50), nullable=False)
    fecha_nacimiento = Column(Date, nullable=False)
    numero_hijos = Column(Integer, nullable=False, default=0)
    tipo_sangre = Column(EnumDB(TipoSangre), nullable=False)
    genero = Column(Boolean, nullable=False)
    direccion = Column(String(100), nullable=False)
    telefono = Column(String(10), nullable=False)
    correo = Column(String(50), nullable=False, unique=True)
    disponibilidad = Column(EnumDB(Disponibilidad), nullable=False)
    estado_civil = Column(EnumDB(EstadoCivil), nullable=False)
    tipo_licencia = Column(EnumDB(TipoLicencia), default=TipoLicencia.NINGUNA)
    vencimiento_licencia = Column(Date)
    antiguedad_conduccion = Column(Integer, default=0)
    hashed_password = Column(String)
    id_rol = Column(Integer, ForeignKey('rol.id_rol'))
    fecha_registro = Column(Date, nullable=False, default=date.today)
    
    # --- RELACIONES CON OTROS MODELOS ---

    # 1. Relación con Rol
    rol = relationship("Rol", back_populates="personas")
    
    # 2. Relación con AsignacionVehiculoConductor
    asignaciones_vehiculos = relationship(
        "AsignacionVehiculoConductor", 
        back_populates="persona",
        lazy="dynamic"
    )

    # 3. Relación con RegistroEntradaSalida
    registros_asistencia = relationship(
        "RegistroEntradaSalida",
        foreign_keys="[RegistroEntradaSalida.id_persona]",
        back_populates="persona",
        cascade="all, delete-orphan"
    )

    # 4. Relaciones con Reemplazo (la persona es reemplazada)
    reemplazos_sufridos = relationship(
        "Reemplazo",
        foreign_keys="[Reemplazo.id_persona_reemplazada]",
        back_populates="persona_reemplazada",
        cascade="all, delete-orphan"
    )

    # 5. Relaciones con Reemplazo (la persona realiza el reemplazo)
    reemplazos_realizados = relationship(
        "Reemplazo",
        foreign_keys="[Reemplazo.id_persona_reemplazo]",
        back_populates="persona_reemplazo",
        cascade="all, delete-orphan"
    )

    # 6. Relación con Proceso
    procesos = relationship(
        "Proceso",
        back_populates="persona",
        cascade="all, delete-orphan"
    )

    # 7. Relación con Hora_Extra
    horas_extras = relationship(
        "Hora_Extra",
        back_populates="persona",
        cascade="all, delete-orphan"
    )

    # 8. Relación con Notificacion (cuando la persona envía) (NUEVA)
    notificaciones_enviadas = relationship(
        "Notificacion",
        foreign_keys="[Notificacion.id_remitente]",
        back_populates="remitente",
        cascade="all, delete-orphan"
    )

    # 9. Relación con Notificacion (cuando la persona recibe) (NUEVA)
    notificaciones_recibidas = relationship(
        "Notificacion",
        foreign_keys="[Notificacion.id_destinatario]",
        back_populates="destinatario",
        cascade="all, delete-orphan"
    )

    # 10. Relación con ProduccionHelados
    producciones_helados = relationship(
        "ProduccionHelados", back_populates="persona", cascade="all, delete-orphan"
    )

    # Relación con procesos
    procesos = relationship("Proceso", back_populates="persona")
    
    # --- Propiedades Calculadas ---
    @property
    def nombre_completo(self):
        return f"{self.nombres} {self.apellidos}"