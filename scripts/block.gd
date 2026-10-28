extends StaticBody2D

signal destroyed

@export var hp: int = 1
@export var points: int = 10
@export var is_strong: bool = false

@onready var visual = $Visual
var is_destroyed: bool = false # ЗАЩИТА

func _ready():
	if is_strong: visual.color = Color("3b82f6")
	else: visual.color = Color("fbbf24")

func hit():
	if is_destroyed: return # Если уже сломан — выходим
	is_destroyed = true # Ставим флаг
	
	if is_strong:
		hp -= 1
		if hp > 0:
			visual.color = Color("1e3a8a")
			is_destroyed = false # Если выжил, снимаем флаг
			return
			
	destroyed.emit()
	queue_free()
