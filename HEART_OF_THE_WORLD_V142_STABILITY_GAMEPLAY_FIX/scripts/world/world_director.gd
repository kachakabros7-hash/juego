extends Node

## Director global del mundo: conecta exploración, zonas, guardado y atmósfera.

var escena_actual: String = ""
var zona_actual: String = ""
var atmosfera: CanvasLayer = null

const ZONAS := {
	"bosque_entrada": "Bosque del Amanecer",
	"bosque_profundidad": "Raíces Profundas",
	"cavernas": "Cavernas Olvidadas",
	"bosque_sendero": "Minas Abandonadas",
	"bosque_santuario": "Ciudad Subterránea",
	"lago_oscuro": "Lago Espectral",
	"ciudad_perdida": "Ruinas del Eco Profundo",
	"pantano_sombrio": "Desierto de Cristal",
	"templo_antiguo": "Templo Ancestral",
	"torre_abismo": "Torre Eclipse",
	"cueva_secreta": "Abismo de la Niebla",
	"jefe_guardian": "El Corazón"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not GameState.checkpoint_activado.is_connected(_on_checkpoint):
		GameState.checkpoint_activado.connect(_on_checkpoint)
	if not GameState.jefe_derrotado_emitido.is_connected(_on_boss):
		GameState.jefe_derrotado_emitido.connect(_on_boss)
	call_deferred("_sincronizar_escena")

func _process(_delta: float) -> void:
	var escena := get_tree().current_scene
	if escena == null:
		return
	var ruta := escena.scene_file_path
	if ruta != escena_actual:
		_actualizar_mundo(ruta)

func _sincronizar_escena() -> void:
	var escena := get_tree().current_scene
	if escena != null:
		_actualizar_mundo(escena.scene_file_path)

func _actualizar_mundo(ruta: String) -> void:
	if ruta.is_empty() or not ruta.contains("/rooms/"):
		return
	escena_actual = ruta
	var archivo := ruta.get_file().get_basename()
	var id_habitacion := archivo
	GameState.registrar_habitacion(id_habitacion)
	var id_zona := _detectar_zona(ruta)
	if id_zona != "":
		zona_actual = id_zona
		GameState.registrar_zona(id_zona)
		GameState.aplicar_balance_zona(id_zona)
		_crear_atmosfera(id_zona)

func _detectar_zona(ruta: String) -> String:
	for id in ZONAS.keys():
		if ruta.contains("/" + id + "/"):
			return id
	return ""

func _crear_atmosfera(id_zona: String) -> void:
	if atmosfera != null and is_instance_valid(atmosfera):
		atmosfera.queue_free()
	atmosfera = CanvasLayer.new()
	atmosfera.name = "WorldAtmosphere"
	atmosfera.layer = 45
	atmosfera.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child.call_deferred(atmosfera)
	var control := Control.new()
	control.set_script(load("res://scripts/world/world_atmosphere.gd"))
	control.name = "Atmosphere"
	atmosfera.add_child(control)
	control.call_deferred("configurar", id_zona)

func _on_checkpoint(_escena: String, _posicion: Vector2) -> void:
	if has_node("/root/SaveManager"):
		SaveManager.call_deferred("guardar_partida")

func _on_boss(_id: String) -> void:
	if has_node("/root/SaveManager"):
		SaveManager.call_deferred("guardar_partida")
