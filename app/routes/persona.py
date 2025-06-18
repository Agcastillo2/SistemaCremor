from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from .. import models, schemas # Asegúrate de que los esquemas (schemas) estén bien definidos
from ..database import get_db
from passlib.context import CryptContext
from pydantic import BaseModel

# --- Configuración del Router ---
router = APIRouter(
    prefix="/personas",
    tags=["personas"],
    responses={404: {"description": "No encontrado"}},
)

# --- Configuración para Hashing de Contraseñas ---
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    """Genera el hash de una contraseña."""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifica si una contraseña en texto plano coincide con su hash."""
    return pwd_context.verify(plain_password, hashed_password)

# --- Modelo Pydantic para el reseteo de contraseña ---
class PasswordReset(BaseModel):
    numero_identificacion: str
    new_password: str

# --- Endpoints del Router ---

@router.post("/", response_model=schemas.Persona, status_code=201)
def create_persona(persona: schemas.PersonaCreate, db: Session = Depends(get_db)):
    """
    Crea una nueva persona en la base de datos.
    """
    # 1. Verificar si el correo ya existe
    if db.query(models.Persona).filter(models.Persona.correo == persona.correo).first():
        raise HTTPException(status_code=400, detail="El correo ya está registrado")
    
    # 2. Verificar si el número de identificación ya existe
    if db.query(models.Persona).filter(models.Persona.numero_identificacion == persona.numero_identificacion).first():
        raise HTTPException(status_code=400, detail="El número de identificación ya está registrado")
    
    # 3. Hashear la contraseña inicial
    hashed_password = get_password_hash(persona.password)
    
    # 4. Crear el objeto de la base de datos (CORREGIDO)
    # Excluimos todos los campos de contraseña que NO están en el modelo de BD `Persona`.
    persona_data = persona.model_dump(exclude={"password", "current_password", "new_password"})
    db_persona = models.Persona(
        **persona_data,
        hashed_password=hashed_password
    )
    
    # 5. Guardar en la base de datos
    db.add(db_persona)
    db.commit()
    db.refresh(db_persona)
    
    return db_persona

@router.get("/", response_model=list[schemas.Persona])
def read_personas(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Obtiene una lista de todas las personas.
    """
    personas = db.query(models.Persona).offset(skip).limit(limit).all()
    return personas

@router.get("/{persona_id}", response_model=schemas.Persona)
def read_persona(persona_id: int, db: Session = Depends(get_db)):
    """
    Obtiene los detalles de una persona específica por su ID.
    """
    db_persona = db.query(models.Persona).filter(models.Persona.id_persona == persona_id).first()
    if db_persona is None:
        raise HTTPException(status_code=404, detail="Persona no encontrada")
    return db_persona

@router.put("/{persona_id}", response_model=schemas.Persona)
def update_persona(persona_id: int, persona_update: schemas.PersonaCreate, db: Session = Depends(get_db)):
    """
    Actualiza la información de una persona y, opcionalmente, su contraseña.
    """
    db_persona = db.query(models.Persona).filter(models.Persona.id_persona == persona_id).first()
    if db_persona is None:
        raise HTTPException(status_code=404, detail="Persona no encontrada")
    
    # 1. Actualizar los campos de datos (excluyendo cualquier campo de contraseña)
    update_data = persona_update.model_dump(exclude_unset=True, exclude={"password", "current_password", "new_password"})
    for field, value in update_data.items():
        setattr(db_persona, field, value)
    
    # 2. Manejar el cambio de contraseña si se proporcionan las contraseñas necesarias
    if persona_update.new_password and persona_update.current_password:
        # Verificar que la contraseña actual sea correcta
        if not verify_password(persona_update.current_password, db_persona.hashed_password):
            raise HTTPException(status_code=400, detail="La contraseña actual es incorrecta")
        # Actualizar a la nueva contraseña
        db_persona.hashed_password = get_password_hash(persona_update.new_password)
    
    db.commit()
    db.refresh(db_persona)
    return db_persona

@router.delete("/{persona_id}", status_code=200)
def delete_persona(persona_id: int, db: Session = Depends(get_db)):
    """
    Elimina una persona de la base de datos.
    """
    db_persona = db.query(models.Persona).filter(models.Persona.id_persona == persona_id).first()
    if db_persona is None:
        raise HTTPException(status_code=404, detail="Persona no encontrada")
    
    db.delete(db_persona)
    db.commit()
    return {"message": "Persona eliminada correctamente"}

@router.post("/login", response_model=schemas.Persona)
def login_persona(credentials: schemas.LoginCredentials, db: Session = Depends(get_db)):
    """
    Autentica a un usuario y devuelve su información, incluyendo su rol.
    """
    db_persona = db.query(models.Persona).options(joinedload(models.Persona.rol)).filter(
        models.Persona.numero_identificacion == credentials.numero_identificacion
    ).first()
    
    if not db_persona or not verify_password(credentials.password, db_persona.hashed_password):
        raise HTTPException(
            status_code=401,
            detail="Credenciales incorrectas",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return db_persona

@router.get("/by-id/{numero_identificacion}", response_model=schemas.Persona)
def get_persona_by_identificacion(numero_identificacion: str, db: Session = Depends(get_db)):
    """
    Obtiene los detalles de una persona por su número de identificación.
    """
    db_persona = db.query(models.Persona).filter(models.Persona.numero_identificacion == numero_identificacion).first()
    if not db_persona:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return db_persona

@router.post("/reset-password", status_code=200)
def reset_password(datos: PasswordReset, db: Session = Depends(get_db)):
    """
    Restablece la contraseña de un usuario usando su número de identificación.
    """
    db_persona = db.query(models.Persona).filter(models.Persona.numero_identificacion == datos.numero_identificacion).first()
    if not db_persona:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    # Actualizar la contraseña con el nuevo hash
    db_persona.hashed_password = get_password_hash(datos.new_password)
    db.commit()
    
    return {"message": "Contraseña actualizada correctamente"}