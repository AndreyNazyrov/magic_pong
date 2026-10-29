extends StaticBody2D

signal destroyed
signal explode(pos: Vector2, radius: float) # <-- Добавили радиус в сигнал

@export var points: int = 30
@export var explosion_radius: float = 80.0
var has_exploded: bool = false

func hit():
	if has_exploded: return
	has_exploded = true
	
	# Вычисляем реальный радиус взрыва с учетом масштаба
	# Если блок отмасштабирован (Scale > 1), увеличиваем радиус
	var real_radius = explosion_radius * max(scale.x, scale.y)
	
	explode.emit(global_position, real_radius) # Передаем радиус
	destroyed.emit()
	queue_free()
