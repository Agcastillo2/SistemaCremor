from pydantic import BaseModel

class LoginCredentials(BaseModel):
    numero_identificacion: str
    password: str
