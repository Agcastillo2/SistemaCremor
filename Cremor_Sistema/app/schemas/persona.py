from datetime import date
from enum import Enum
from pydantic import BaseModel, EmailStr
from typing import Optional

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

class PersonaBase(BaseModel):
    numero_identificacion: str
    nombres: str
    apellidos: str
    fecha_nacimiento: date
    numero_hijos:int = 0
    tipo_sangre: TipoSangre = TipoSangre.A_POSITIVO
    genero: bool
    direccion: str
    telefono: str
    correo: EmailStr
    disponibilidad: Disponibilidad
    estado_civil: EstadoCivil
    tipo_licencia: TipoLicencia = TipoLicencia.NINGUNA
    vencimiento_licencia: Optional[date] = None
    antiguedad_conduccion: int = 0

class PersonaCreate(PersonaBase):
    password: str  # Contraseña en texto plano para el registro

class Persona(PersonaBase):
    id_persona: int
    fecha_registro: date
    nombre_completo: str

    class Config:
        from_attributes = True