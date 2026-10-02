extends Node

## HEART OF THE WORLD — Global Game State
## Versión corregida para Godot 4.7


# ============================================================
# SEÑALES
# ============================================================

signal vida_cambiada(actual: int, maxima: int)
signal monedas_cambiadas(cantidad: int)
signal habilidad_desbloqueada(nombre: String)
signal enemigo_derrotado(id: String)

# IMPORTANTE:
# Esta señal NO puede llamarse igual que la función jefe_derrotado().
signal jefe_derrotado_emitido(id: String)

signal checkpoint_activado(escena: String, posicion: Vector2)
signal habitacion_descubierta(nombre: String)
signal zona_descubierta(nombre: String)


# ============================================================
# PROGRESO DEL JUGADOR
# ============================================================

var vida_maxima: int = 100
var vida_actual: int = 100
var monedas: int = 0
var pociones: int = 2
var pociones_maximas: int = 9

var mejora_vida: int = 0
var mejora_dano: int = 0
var bonus_vida_fragmentos: int = 0

var nivel_arma: int = 1
var nivel_arma_maximo: int = 6

var mejora_dash: int = 0


# ============================================================
# EXPLORACIÓN Y PROGRESO
# ============================================================

var zonas_descubiertas: Dictionary = {}
var habitaciones_descubiertas: Dictionary = {}
var salas_secretas_descubiertas: Dictionary = {}
var zona_actual: String = ""
var habitacion_actual: String = ""

var recompensas_especiales: Dictionary = {}
var puertas_recordadas: Dictionary = {}
var salas_completadas: Dictionary = {}

var jefes_derrotados: Dictionary = {}

# Fragmentos del Corazón y restauración del mundo
var fragmentos_corazon: Dictionary = {}
var bosque_restaurado: bool = false
var memorias_descubiertas: Dictionary = {}

# Decisión narrativa de Luma. Se mantiene durante la partida actual.
var decision_luma: String = ""
var criaturas_perdonadas: int = 0
var criaturas_derrotadas: int = 0
var encuentros_resueltos: Dictionary = {}

func registrar_decision_luma(decision: String) -> void:
	if decision in ["escuchar", "proteger"]:
		decision_luma = decision

func registrar_resultado_criatura(perdonada: bool) -> void:
	if perdonada:
		criaturas_perdonadas += 1
	else:
		criaturas_derrotadas += 1

func registrar_encuentro(identificador: String, resultado: String) -> void:
	if identificador.is_empty() or not resultado in ["perdonada", "derrotada"]:
		return
	encuentros_resueltos[identificador] = resultado
	registrar_resultado_criatura(resultado == "perdonada")

func encuentro_resuelto(identificador: String) -> bool:
	return encuentros_resueltos.has(identificador)



# ============================================================
# CHECKPOINT / SPAWN
# ============================================================

var checkpoint_escena: String = ""
var checkpoint_posicion: Vector2 = Vector2.ZERO

var posicion_spawn: Vector2 = Vector2.ZERO
var punto_spawn: String = "PlayerSpawn"

var portales_bloqueados_hasta: int = 0


# ============================================================
# TUTORIALES
# ============================================================

var tutoriales_vistos: Dictionary = {}


# ============================================================
# BALANCE GLOBAL
# ============================================================

var multiplicador_dano_enemigo: float = 1.0
var multiplicador_vida_enemigo: float = 1.0
var multiplicador_recompensa: float = 1.0


# ============================================================
# SECRETOS Y CONTEXTO DEL MUNDO
# ============================================================

func registrar_sala_secreta(identificador: String) -> void:
	if identificador.is_empty():
		return
	salas_secretas_descubiertas[identificador] = true

func sala_secreta_descubierta(identificador: String) -> bool:
	return bool(salas_secretas_descubiertas.get(identificador, false))

# ============================================================
# HABILIDADES
# ============================================================

var habilidades: Dictionary = {
	"double_jump": false,
	"dash": false,
	"mantis_claw": false,
	"crystal_heart": false,
	"isma_tear": false,
	"shade_cloak": false,
	"root_burst": false
}


# ============================================================
# PORTALES
# ============================================================

func bloquear_portales(duracion_ms: int = 700) -> void:
	portales_bloqueados_hasta = Time.get_ticks_msec() + duracion_ms


func portales_bloqueados() -> bool:
	return Time.get_ticks_msec() < portales_bloqueados_hasta


# ============================================================
# ZONAS
# ============================================================

func registrar_zona(nombre: String) -> void:
	if nombre.is_empty():
		return

	var era_nueva := not zonas_descubiertas.has(nombre)
	zonas_descubiertas[nombre] = true
	zona_actual = nombre
	if era_nueva:
		zona_descubierta.emit(nombre)


# ============================================================
# HABITACIONES
# ============================================================

func registrar_habitacion(nombre: String) -> void:
	if nombre.is_empty():
		return

	habitaciones_descubiertas[nombre] = true
	habitacion_actual = nombre
	habitacion_descubierta.emit(nombre)


# ============================================================
# HABILIDADES
# ============================================================

func tiene_habilidad(nombre: String) -> bool:
	return bool(habilidades.get(nombre, false))


func obtener_habilidad(nombre: String) -> void:
	if not habilidades.has(nombre):
		return

	if habilidades[nombre]:
		return

	habilidades[nombre] = true
	habilidad_desbloqueada.emit(nombre)


# ============================================================
# PUERTAS
# ============================================================

func registrar_puerta_bloqueada(
	identificador: String,
	habilidad: String
) -> void:
	puertas_recordadas[identificador] = habilidad


# ============================================================
# SALAS COMPLETADAS
# ============================================================

func registrar_sala_completada(nombre: String) -> void:
	salas_completadas[nombre] = true


# ============================================================
# JEFES / GUARDIANES
# ============================================================

func registrar_fragmento_corazon(identificador: String) -> void:
	if identificador.is_empty():
		return
	fragmentos_corazon[identificador] = true
	if identificador == "corazon_fragmento_01":
		bosque_restaurado = true

func tiene_fragmento_corazon(identificador: String) -> bool:
	return bool(fragmentos_corazon.get(identificador, false))

func cantidad_fragmentos_corazon() -> int:
	return fragmentos_corazon.size()

func registrar_memoria(identificador: String) -> void:
	if identificador.is_empty():
		return
	memorias_descubiertas[identificador] = true

func tiene_memoria(identificador: String) -> bool:
	return bool(memorias_descubiertas.get(identificador, false))

func cantidad_memorias() -> int:
	return memorias_descubiertas.size()

func registrar_jefe_derrotado(identificador: String) -> void:

	if jefes_derrotados.get(identificador, false):
		return

	jefes_derrotados[identificador] = true

	jefe_derrotado_emitido.emit(identificador)


func jefe_derrotado(identificador: String) -> bool:
	return bool(
		jefes_derrotados.get(
			identificador,
			false
		)
	)


# ============================================================
# RECOMPENSAS ESPECIALES
# ============================================================

func registrar_recompensa_especial(
	identificador: String
) -> void:
	recompensas_especiales[identificador] = true


func tiene_recompensa_especial(
	identificador: String
) -> bool:
	return bool(
		recompensas_especiales.get(
			identificador,
			false
		)
	)


# ============================================================
# CHECKPOINT
# ============================================================

func activar_checkpoint(
	escena: String,
	posicion: Vector2
) -> void:

	checkpoint_escena = escena
	checkpoint_posicion = posicion

	checkpoint_activado.emit(
		escena,
		posicion
	)




# ============================================================
# POCIONES
# ============================================================

func agregar_pociones(cantidad: int = 1) -> void:
	pociones = clampi(pociones + cantidad, 0, pociones_maximas)


func usar_pocion() -> bool:
	if pociones <= 0:
		return false
	pociones -= 1
	return true


func registrar_enemigo_derrotado(identificador: String = "") -> void:
	enemigo_derrotado.emit(identificador)
	if has_node("/root/MissionManager"):
		MissionManager.registrar_enemigo_derrotado(identificador)

# ============================================================
# VIDA
# ============================================================

func establecer_vida(cantidad: int) -> void:

	vida_actual = clampi(
		cantidad,
		0,
		vida_maxima
	)

	vida_cambiada.emit(
		vida_actual,
		vida_maxima
	)


func curar(cantidad: int) -> void:

	vida_actual = mini(
		vida_actual + cantidad,
		vida_maxima
	)

	vida_cambiada.emit(
		vida_actual,
		vida_maxima
	)


func recibir_dano(cantidad: int) -> void:

	vida_actual = maxi(
		vida_actual - cantidad,
		0
	)

	vida_cambiada.emit(
		vida_actual,
		vida_maxima
	)


# ============================================================
# MONEDAS
# ============================================================

func agregar_monedas(cantidad: int) -> void:

	monedas = maxi(
		monedas + cantidad,
		0
	)

	monedas_cambiadas.emit(monedas)


# ============================================================
# DAÑO DEL ARMA
# ============================================================

func obtener_dano_arma() -> int:

	return 25 + maxi(
		nivel_arma - 1,
		0
	) * 8


# ============================================================
# MEJORAR ARMA
# ============================================================

func mejorar_arma() -> bool:

	if nivel_arma >= nivel_arma_maximo:
		return false

	nivel_arma += 1

	mejora_dano = maxi(
		nivel_arma - 1,
		mejora_dano
	)

	return true


# ============================================================
# COMPRAR MEJORA
# ============================================================

func comprar_mejora(
	tipo: String,
	costo: int
) -> bool:

	if monedas < costo:
		return false

	monedas -= costo

	match tipo:

		"vida":
			mejora_vida += 1

		"dano":
			if not mejorar_arma():
				monedas += costo
				return false

		"dash":
			mejora_dash += 1

		_:
			monedas += costo
			return false

	monedas_cambiadas.emit(monedas)

	return true


# ============================================================
# REINICIAR ESTADO
# ============================================================

func reiniciar_estado() -> void:

	vida_maxima = 100
	vida_actual = 100
	monedas = 0
	pociones = 2

	mejora_vida = 0
	mejora_dano = 0
	bonus_vida_fragmentos = 0

	nivel_arma = 1
	mejora_dash = 0


	# EXPLORACIÓN
	zonas_descubiertas.clear()
	habitaciones_descubiertas.clear()
	salas_secretas_descubiertas.clear()
	zona_actual = ""
	habitacion_actual = ""

	recompensas_especiales.clear()
	puertas_recordadas.clear()
	salas_completadas.clear()

	jefes_derrotados.clear()
	fragmentos_corazon.clear()
	bosque_restaurado = false
	memorias_descubiertas.clear()
	decision_luma = ""
	criaturas_perdonadas = 0
	criaturas_derrotadas = 0
	encuentros_resueltos.clear()


	# CHECKPOINT
	checkpoint_escena = ""
	checkpoint_posicion = Vector2.ZERO

	posicion_spawn = Vector2.ZERO
	punto_spawn = "PlayerSpawn"

	portales_bloqueados_hasta = 0


	# TUTORIALES
	tutoriales_vistos.clear()


	# BALANCE
	multiplicador_dano_enemigo = 1.0
	multiplicador_vida_enemigo = 1.0
	multiplicador_recompensa = 1.0


	# HABILIDADES
	habilidades = {
		"double_jump": false,
		"dash": false,
		"mantis_claw": false,
		"crystal_heart": false,
		"isma_tear": false,
		"shade_cloak": false,
		"root_burst": false
	}


	# ACTUALIZAR HUD
	vida_cambiada.emit(
		vida_actual,
		vida_maxima
	)

	monedas_cambiadas.emit(monedas)


# ============================================================
# BALANCE POR ZONA
# ============================================================

func aplicar_balance_zona(zona_id: String) -> void:

	match zona_id:

		"bosque_entrada":
			multiplicador_dano_enemigo = 0.85
			multiplicador_vida_enemigo = 0.90
			multiplicador_recompensa = 1.10

		"bosque_profundidad", "cavernas":
			multiplicador_dano_enemigo = 1.00
			multiplicador_vida_enemigo = 1.00
			multiplicador_recompensa = 1.00

		"templo_antiguo", "ciudad_perdida", "pantano_sombrio":
			multiplicador_dano_enemigo = 1.15
			multiplicador_vida_enemigo = 1.20
			multiplicador_recompensa = 1.05

		"jefe_guardian", "torre_abismo":
			multiplicador_dano_enemigo = 1.25
			multiplicador_vida_enemigo = 1.30
			multiplicador_recompensa = 1.15

		_:
			multiplicador_dano_enemigo = 1.0
			multiplicador_vida_enemigo = 1.0
			multiplicador_recompensa = 1.0
