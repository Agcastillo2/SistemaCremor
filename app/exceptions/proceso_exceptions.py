class ProcesoException(Exception):
    """Excepción base para errores en procesos"""
    pass

class ProcesoNoEncontradoError(ProcesoException):
    """Se lanza cuando no se encuentra un proceso"""
    pass

class ProcesoEnProgresoError(ProcesoException):
    """Se lanza cuando se intenta iniciar un proceso mientras hay otro en progreso"""
    pass

class OrdenProcesoInvalidoError(ProcesoException):
    """Se lanza cuando el orden de los procesos X e Y no es válido"""
    pass

class PermisoProcesoError(ProcesoException):
    """Se lanza cuando un usuario no tiene permisos para modificar un proceso"""
    pass

class DatosProcesoInvalidosError(ProcesoException):
    """Se lanza cuando los datos del proceso son inválidos"""
    pass
