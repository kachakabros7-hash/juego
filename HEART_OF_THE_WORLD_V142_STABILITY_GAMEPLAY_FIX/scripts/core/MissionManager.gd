extends Node

## HEART OF THE WORLD — Sistema de misiones
## Primera misión: Ecos del Bosque.
## Diseñado para crecer con Luma sin depender de ella todavía.

signal mision_cambiada(id: String, estado: int, progreso: int, objetivo: int)
signal objetivo_actualizado(progreso: int, objetivo: int)
signal mision_completada(id: String)

const NO_INICIADA: int = 0
const ACTIVA: int = 1
const COMPLETADA: int = 2

var mision_actual: String = "ecos_del_bosque"
var estado_actual: int = NO_INICIADA
var progreso: int = 0
var objetivo: int = 3
var recompensa_pendiente: bool = false

func _ready() -> void:
    # La misión queda preparada, pero no se inicia automáticamente.
    # Luma podrá activarla más adelante.
    pass

func iniciar_mision(id: String = "ecos_del_bosque") -> bool:
    if id != "ecos_del_bosque":
        return false
    if estado_actual == ACTIVA:
        return false
    if estado_actual == COMPLETADA:
        return false
    mision_actual = id
    estado_actual = ACTIVA
    progreso = 0
    objetivo = 3
    recompensa_pendiente = false
    _emitir_cambio()
    return true

func registrar_enemigo_derrotado(_identificador: String = "") -> void:
    if estado_actual != ACTIVA:
        return
    progreso = mini(progreso + 1, objetivo)
    objetivo_actualizado.emit(progreso, objetivo)
    if progreso >= objetivo:
        estado_actual = COMPLETADA
        recompensa_pendiente = true
        mision_completada.emit(mision_actual)
        _emitir_cambio()

func entregar_recompensa() -> bool:
    if estado_actual != COMPLETADA or not recompensa_pendiente:
        return false
    GameState.agregar_pociones(1)
    recompensa_pendiente = false
    return true

func reiniciar() -> void:
    mision_actual = "ecos_del_bosque"
    estado_actual = NO_INICIADA
    progreso = 0
    objetivo = 3
    recompensa_pendiente = false
    _emitir_cambio()

func nombre_mision() -> String:
    match mision_actual:
        "ecos_del_bosque":
            return "ECOS DEL BOSQUE"
        _:
            return mision_actual

func descripcion_mision() -> String:
    match mision_actual:
        "ecos_del_bosque":
            return "Derrota 3 criaturas cerca de las raíces."
        _:
            return "Explora el mundo."

func estado_texto() -> String:
    match estado_actual:
        NO_INICIADA:
            return "NO INICIADA"
        ACTIVA:
            return "ACTIVA"
        COMPLETADA:
            return "COMPLETADA"
        _:
            return "DESCONOCIDA"

func _emitir_cambio() -> void:
    mision_cambiada.emit(mision_actual, estado_actual, progreso, objetivo)
