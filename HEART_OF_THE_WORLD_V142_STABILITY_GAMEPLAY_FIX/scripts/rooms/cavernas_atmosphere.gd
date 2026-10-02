extends Node2D

const ROOM_DATA: Dictionary = {
	"cavernas_pasaje": ["PASO DE LAS ESTALACTITAS", "El silencio aquí no está vacío. Escucha la piedra."],
	"cavernas_desafio": ["PUENTE DEL ECO", "Cada salto devuelve un sonido distinto."],
	"cavernas_recompensa": ["CÁMARA DE CRISTALES", "Los cristales guardan pequeños recuerdos del mundo."],
	"cavernas_secreta": ["HUECO DE LA MEMORIA", "Algo antiguo fue dejado aquí para quien supiera escuchar."]
}

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var id := get_tree().current_scene.scene_file_path.get_file().get_basename()
	var data: Array = ROOM_DATA.get(id, ["CAVERNAS OLVIDADAS", "La piedra conserva lo que el tiempo intenta borrar."])
	# Profundidad de caverna: siluetas, grietas y pequeños cristales.
	draw_rect(Rect2(50, 50, 4050, 1290), Color(0.018, 0.015, 0.025, 0.72))
	for x in range(180, 4050, 360):
		var h := 90.0 + float((x * 17) % 150)
		draw_polygon(PackedVector2Array([
			Vector2(x - 70, 70), Vector2(x + 70, 70), Vector2(x + 25, 70 + h), Vector2(x - 18, 70 + h * 0.72)
		]), PackedColorArray([Color(0.10, 0.075, 0.11, 0.95)]))
	for x in range(320, 4000, 430):
		var h := 110.0 + float((x * 11) % 130)
		draw_polygon(PackedVector2Array([
			Vector2(x - 55, 1340), Vector2(x + 55, 1340), Vector2(x + 18, 1340 - h), Vector2(x - 22, 1340 - h * 0.65)
		]), PackedColorArray([Color(0.075, 0.06, 0.085, 0.95)]))
	for p in [Vector2(540,1120), Vector2(1220,840), Vector2(1980,1110), Vector2(2780,760), Vector2(3520,1080)]:
		draw_line(p, p + Vector2(25, 80), Color(0.38, 0.25, 0.48, 0.35), 5.0)
		draw_line(p + Vector2(25, 80), p + Vector2(55, 135), Color(0.45, 0.30, 0.55, 0.28), 3.0)
		draw_circle(p + Vector2(4, 6), 8.0, Color(0.65, 0.45, 0.72, 0.45))
	draw_string(ThemeDB.fallback_font, Vector2(90, 205), "CAVERNAS OLVIDADAS", HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color(0.82, 0.72, 0.88, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(90, 250), str(data[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.68, 0.52, 0.76, 0.95))
	draw_string(ThemeDB.fallback_font, Vector2(90, 286), str(data[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.55, 0.49, 0.61, 0.92))
