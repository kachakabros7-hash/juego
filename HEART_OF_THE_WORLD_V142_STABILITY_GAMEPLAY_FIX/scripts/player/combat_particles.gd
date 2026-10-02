extends Node2D

## Partículas simples de combate (golpe / daño) — sin assets externos.

func spawn_hit(pos: Vector2, color: Color = Color(0.35, 0.9, 1.0, 1.0)) -> void:
	_burst(pos, color, 10, 90.0, 0.25)


func spawn_hurt(pos: Vector2) -> void:
	_burst(pos, Color(1.0, 0.35, 0.4, 1.0), 8, 70.0, 0.3)


func _burst(pos: Vector2, color: Color, count: int, speed: float, life: float) -> void:
	var parent := get_tree().current_scene
	if parent == null:
		parent = self
	for i in count:
		var p := _Particle.new()
		p.global_position = pos
		p.velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(speed * 0.4, speed)
		p.color = color
		p.life = life * randf_range(0.7, 1.2)
		parent.add_child(p)


class _Particle extends Node2D:
	var velocity: Vector2 = Vector2.ZERO
	var color: Color = Color.WHITE
	var life: float = 0.3
	var _t: float = 0.0
	var _r: float = 3.0

	func _ready() -> void:
		z_index = 50
		_r = randf_range(2.0, 4.5)

	func _process(delta: float) -> void:
		_t += delta
		if _t >= life:
			queue_free()
			return
		velocity.y += 400.0 * delta
		position += velocity * delta
		velocity *= 0.92
		queue_redraw()

	func _draw() -> void:
		var a := 1.0 - (_t / life)
		draw_circle(Vector2.ZERO, _r * a, Color(color.r, color.g, color.b, a))
