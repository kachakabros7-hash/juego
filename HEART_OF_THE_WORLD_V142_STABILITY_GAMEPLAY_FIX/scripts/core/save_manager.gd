extends Node

## HEART OF THE WORLD — Save System
## Versión mejorada: más robusta, con validación y fallbacks seguros.

const SAVE_PATH: String = "user://misha_corazon_del_mundo_save.json"
const SAVE_VERSION: int = 6

const ESCENA_INICIO_SEGURA: String = "res://scenes/rooms/bosque/bosque_entrada.tscn"
const SPAWN_INICIO_SEGURO: Vector2 = Vector2(274.4, 1227.2)

signal partida_guardada
signal partida_cargada
signal error_guardado(mensaje: String)

func existe_guardado() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func guardar_partida() -> bool:
	var escena: Node = get_tree().current_scene
	if escena == null:
		error_guardado.emit("No hay escena actual")
		return false

	var posicion: Vector2 = GameState.posicion_spawn
	var player: Node = get_tree().get_first_node_in_group("player")
	if player is Node2D:
		posicion = player.global_position

	var data: Dictionary = {
		"version": SAVE_VERSION,
		"scene": escena.scene_file_path,
		"player_position": {"x": posicion.x, "y": posicion.y},
		"vida_actual": GameState.vida_actual,
		"vida_maxima": GameState.vida_maxima,
		"monedas": GameState.monedas,
		"pociones": GameState.pociones,
		"pociones_maximas": GameState.pociones_maximas,
		"mejora_vida": GameState.mejora_vida,
		"mejora_dano": GameState.mejora_dano,
		"bonus_vida_fragmentos": GameState.bonus_vida_fragmentos,
		"nivel_arma": GameState.nivel_arma,
		"mejora_dash": GameState.mejora_dash,
		"habilidades": GameState.habilidades.duplicate(true),
		"zonas_descubiertas": GameState.zonas_descubiertas.duplicate(true),
		"habitaciones_descubiertas": GameState.habitaciones_descubiertas.duplicate(true),
		"salas_secretas_descubiertas": GameState.salas_secretas_descubiertas.duplicate(true),
		"zona_actual": GameState.zona_actual,
		"habitacion_actual": GameState.habitacion_actual,
		"recompensas_especiales": GameState.recompensas_especiales.duplicate(true),
		"puertas_recordadas": GameState.puertas_recordadas.duplicate(true),
		"salas_completadas": GameState.salas_completadas.duplicate(true),
		"jefes_derrotados": GameState.jefes_derrotados.duplicate(true),
		"fragmentos_corazon": GameState.fragmentos_corazon.duplicate(true),
		"bosque_restaurado": GameState.bosque_restaurado,
		"memorias_descubiertas": GameState.memorias_descubiertas.duplicate(true),
		"decision_luma": GameState.decision_luma,
		"criaturas_perdonadas": GameState.criaturas_perdonadas,
		"criaturas_derrotadas": GameState.criaturas_derrotadas,
		"encuentros_resueltos": GameState.encuentros_resueltos.duplicate(true),
		"mision_actual": MissionManager.mision_actual,
		"mision_estado": MissionManager.estado_actual,
		"mision_progreso": MissionManager.progreso,
		"mision_objetivo": MissionManager.objetivo,
		"mision_recompensa_pendiente": MissionManager.recompensa_pendiente,
		"tutoriales_vistos": GameState.tutoriales_vistos.duplicate(true),
		"checkpoint_escena": GameState.checkpoint_escena,
		"checkpoint_posicion": {
			"x": GameState.checkpoint_posicion.x,
			"y": GameState.checkpoint_posicion.y
		}
	}

	var ruta: String = ProjectSettings.globalize_path(SAVE_PATH)
	var temporal: String = ruta + ".tmp"
	var respaldo: String = ruta + ".bak"
	var file: FileAccess = FileAccess.open(temporal, FileAccess.WRITE)
	if file == null:
		error_guardado.emit("No se pudo crear el guardado temporal")
		return false

	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	file.close()

	if FileAccess.file_exists(ruta):
		DirAccess.copy_absolute(ruta, respaldo)
		DirAccess.remove_absolute(ruta)

	var renombrado: Error = DirAccess.rename_absolute(temporal, ruta)
	if renombrado != OK:
		if FileAccess.file_exists(temporal):
			DirAccess.remove_absolute(temporal)
		if FileAccess.file_exists(respaldo) and not FileAccess.file_exists(ruta):
			DirAccess.copy_absolute(respaldo, ruta)
		error_guardado.emit("No se pudo finalizar el guardado")
		return false

	partida_guardada.emit()
	return true


func cargar_partida() -> bool:
	if not existe_guardado():
		return false

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		error_guardado.emit("No se pudo leer el guardado")
		return false

	var texto: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(texto)
	if not parsed is Dictionary:
		error_guardado.emit("Guardado corrupto")
		return false

	var data: Dictionary = parsed
	var version_guardado: int = int(data.get("version", 1))
	if version_guardado > SAVE_VERSION:
		error_guardado.emit("Guardado de una versión más nueva")
		return false

	# Partimos de los valores por defecto actuales y fusionamos lo que exista.
	GameState.reiniciar_estado()

	# Restaurar progreso
	GameState.vida_maxima = maxi(int(data.get("vida_maxima", 100)), 1)
	GameState.vida_actual = clampi(int(data.get("vida_actual", GameState.vida_maxima)), 0, GameState.vida_maxima)
	GameState.monedas = maxi(int(data.get("monedas", 0)), 0)
	GameState.pociones = clampi(int(data.get("pociones", 2)), 0, GameState.pociones_maximas)
	GameState.pociones_maximas = maxi(int(data.get("pociones_maximas", GameState.pociones_maximas)), 1)
	GameState.pociones = clampi(GameState.pociones, 0, GameState.pociones_maximas)
	GameState.mejora_vida = maxi(int(data.get("mejora_vida", 0)), 0)
	GameState.mejora_dano = maxi(int(data.get("mejora_dano", 0)), 0)
	var bonus_guardado: int = maxi(int(data.get("bonus_vida_fragmentos", 0)), 0)
	if not data.has("bonus_vida_fragmentos"):
		var base_vida: int = 100 + GameState.mejora_vida * 25
		bonus_guardado = maxi(int(data.get("vida_maxima", base_vida)) - base_vida, 0)
	GameState.bonus_vida_fragmentos = bonus_guardado
	GameState.nivel_arma = clampi(int(data.get("nivel_arma", 1)), 1, GameState.nivel_arma_maximo)
	GameState.mejora_dash = maxi(int(data.get("mejora_dash", 0)), 0)

	_restaurar_diccionario(data, "habilidades", GameState.habilidades)
	_restaurar_diccionario(data, "zonas_descubiertas", GameState.zonas_descubiertas)
	_restaurar_diccionario(data, "habitaciones_descubiertas", GameState.habitaciones_descubiertas)
	_restaurar_diccionario(data, "salas_secretas_descubiertas", GameState.salas_secretas_descubiertas)
	GameState.zona_actual = str(data.get("zona_actual", ""))
	GameState.habitacion_actual = str(data.get("habitacion_actual", ""))
	_restaurar_diccionario(data, "puertas_recordadas", GameState.puertas_recordadas)
	_restaurar_diccionario(data, "salas_completadas", GameState.salas_completadas)
	_restaurar_diccionario(data, "jefes_derrotados", GameState.jefes_derrotados)
	_restaurar_diccionario(data, "fragmentos_corazon", GameState.fragmentos_corazon)
	_restaurar_diccionario(data, "memorias_descubiertas", GameState.memorias_descubiertas)
	GameState.decision_luma = str(data.get("decision_luma", ""))
	GameState.criaturas_perdonadas = maxi(int(data.get("criaturas_perdonadas", 0)), 0)
	GameState.criaturas_derrotadas = maxi(int(data.get("criaturas_derrotadas", 0)), 0)
	_restaurar_diccionario(data, "encuentros_resueltos", GameState.encuentros_resueltos)
	GameState.bosque_restaurado = bool(data.get("bosque_restaurado", GameState.tiene_fragmento_corazon("corazon_fragmento_01")))
	_restaurar_diccionario(data, "recompensas_especiales", GameState.recompensas_especiales)
	_restaurar_diccionario(data, "tutoriales_vistos", GameState.tutoriales_vistos)

	GameState.checkpoint_escena = str(data.get("checkpoint_escena", ""))
	GameState.checkpoint_posicion = _vector_desde(data.get("checkpoint_posicion", {}))
	GameState.posicion_spawn = _vector_desde(data.get("player_position", {}))
	GameState.punto_spawn = ""

	# Restaurar la misión antes de abrir la escena, para que Luma y el fragmento
	# conozcan inmediatamente el progreso guardado.
	MissionManager.mision_actual = str(data.get("mision_actual", "ecos_del_bosque"))
	MissionManager.estado_actual = clampi(int(data.get("mision_estado", MissionManager.NO_INICIADA)), MissionManager.NO_INICIADA, MissionManager.COMPLETADA)
	MissionManager.progreso = maxi(int(data.get("mision_progreso", 0)), 0)
	MissionManager.objetivo = maxi(int(data.get("mision_objetivo", 3)), 1)
	MissionManager.recompensa_pendiente = bool(data.get("mision_recompensa_pendiente", false))

	# Escena segura
	var escena_guardada: String = str(data.get("scene", ""))
	if escena_guardada.is_empty() or not ResourceLoader.exists(escena_guardada):
		escena_guardada = ESCENA_INICIO_SEGURA
		GameState.posicion_spawn = SPAWN_INICIO_SEGURO
		GameState.punto_spawn = "PlayerSpawn"

	var resultado: Error = get_tree().change_scene_to_file(escena_guardada)
	if resultado != OK:
		error_guardado.emit("No se pudo cargar la escena: " + escena_guardada)
		return false

	partida_cargada.emit()
	return true


func nueva_partida() -> void:
	GameState.reiniciar_estado()
	borrar_guardado()


func borrar_guardado() -> void:
	if existe_guardado():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func _restaurar_diccionario(data: Dictionary, clave: String, destino: Dictionary) -> void:
	var valor: Variant = data.get(clave, {})
	if valor is Dictionary:
		for k in valor:
			destino[k] = valor[k]


func _vector_desde(valor: Variant) -> Vector2:
	if valor is Vector2:
		return valor
	if valor is Dictionary:
		return Vector2(float(valor.get("x", 0.0)), float(valor.get("y", 0.0)))
	if valor is Array and valor.size() >= 2:
		return Vector2(float(valor[0]), float(valor[1]))
	return Vector2.ZERO
