extends StaticBody2D

signal destroyed
signal explode(pos: Vector2)

@export var points: int = 30
@export var explosion_radius: float = 80.0

var has_exploded: bool = false

func hit():
	if has_exploded: return
	has_exploded = true
	explode.emit(global_position)
	destroyed.emit()
	queue_free()
