extends StaticBody2D

signal destroyed
@export var points: int = 50 # Цели дают больше очков

func hit():
	destroyed.emit()
	queue_free()
