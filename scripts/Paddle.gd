extends CharacterBody2D

@export var speed: float = 600.0
@export var follow_speed: float = 20.0

var is_charged: bool = false
var target_x: float = 0.0
var paddle_half_width: float = 80.0

func _ready():
	target_x = position.x

func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_x = event.position.x
	elif event is InputEventScreenDrag:
		target_x = event.position.x
	elif event is InputEventMouseButton and event.pressed:
		target_x = event.position.x
	elif event is InputEventScreenTouch and event.pressed:
		target_x = event.position.x

func _physics_process(delta):
	var min_x = paddle_half_width + 10
	var max_x = 720 - paddle_half_width - 10
	target_x = clamp(target_x, min_x, max_x)
	position.x = lerp(position.x, target_x, follow_speed * delta)
