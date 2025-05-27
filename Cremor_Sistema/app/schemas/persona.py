from datetime import date
from enum import Enum
from pydantic import BaseModel, EmailStr
from typing import Optional
from .rol import NombreRol, Rol

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
    numero_hijos: int = 0
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
    id_rol: Optional[int] = None

class PersonaCreate(PersonaBase):
    password: str
    current_password: Optional[str] = None  # Campo para validar contraseña actual
    new_password: Optional[str] = None      # Campo para nueva contraseña

class Persona(PersonaBase):
    id_persona: int
    fecha_registro: date
    nombre_completo: str
    rol: Optional[Rol] = None  # El rol es opcional

    class Config:
        from_attributes = True
        
    def model_dump(self, *args, **kwargs):
        data = super().model_dump(*args, **kwargs)
        # Ensure role fields are properly serialized
        if 'rol' in data and data['rol'] is not None and self.rol is not None:
            data['rol'] = {
                'id_rol': self.rol.id_rol,
                'nombre_rol': self.rol.nombre_rol.value,  # Convert enum to string
                'descripcion_rol': self.rol.descripcion_rol,
                'departamento': self.rol.departamento,
                'activo': self.rol.activo
            }
        else:
            # Crear un rol por defecto para evitar errores de validación
            data['rol'] = {
                'id_rol': 1,  # Rol por defecto
                'nombre_rol': 'SUPERVISOR',
                'descripcion_rol': 'Rol por defecto',
                'departamento': 'General',
                'activo': True
            }
        return data