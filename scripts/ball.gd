extends CharacterBody2D

signal hit_paddle

@export var base_speed: float = 400.0
@export var speed_increase: float = 10.0

var current_speed: float = 400.0
var is_accelerated: bool = false
var stuck_timer: float = 0.0
var has_chain: bool = false
var can_move: bool = false
var is_waiting_start: bool = true
var paddle_ref: Node2D = null

func _ready():
	add_to_group("balls")
	randomize()
	
	var points = PackedVector2Array()
	for i in range(16):
		var angle = i * (2 * PI / 16)
		points.append(Vector2(cos(angle), sin(angle)) * 15)
	$Visual.polygon = points
	$Visual.color = Color("a78bfa")
	
	# Ждем 2 кадра для физики
	await get_tree().process_frame
	await get_tree().process_frame
	can_move = true

func _input(event):
	if not is_waiting_start: return
	if event is InputEventMouseButton and event.pressed:
		launch_ball()
	elif event is InputEventScreenTouch and event.pressed:
		launch_ball()

func launch_ball():
	is_waiting_start = false
	var angle = randf_range(-PI/6, PI/6) - PI/2
	velocity = Vector2(cos(angle), sin(angle)) * base_speed

func _physics_process(delta):
	if is_waiting_start:
		if paddle_ref:
			position = paddle_ref.position + Vector2(0, -50)
		return
		
	if not can_move: return
		
	if position.y > 1350 or position.y < -50 or position.x < -50 or position.x > 770:
		reset_ball()
		return
		
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider.name == "Paddle":
			hit_paddle.emit()
			reset_acceleration()
			if collider.is_charged:
				has_chain = true
				collider.is_charged = false
			
			var normal = collision.get_normal()
			var new_velocity = velocity.bounce(normal)
			var paddle_half = 80.0
			var offset = (global_position.x - paddle_ref.global_position.x) / paddle_half
			offset = clamp(offset, -1.0, 1.0)
			
			if normal.y < 0:
				var angle_offset = offset * deg_to_rad(60)
				new_velocity.x += sin(angle_offset) * current_speed
				new_velocity.y = -abs(new_velocity.y)
			
			velocity = new_velocity.normalized() * current_speed
			return
			
		elif collider is StaticBody2D and collider.has_method("hit"):
			collider.hit()
			if has_chain:
				has_chain = false
				get_parent().destroy_random_nearby(collider.global_position, 3)
		
		velocity = velocity.bounce(collision.get_normal())
		current_speed += speed_increase
		velocity = velocity.normalized() * current_speed
		velocity = clamp_angle(velocity)
		stuck_timer += delta
		if stuck_timer > 1.5:
			stuck_timer = 0.0
			reset_ball()
			return
	else:
		stuck_timer = 0.0

func reset_ball():
	position = paddle_ref.position + Vector2(0, -50)
	is_accelerated = false
	stuck_timer = 0.0
	has_chain = false
	current_speed = base_speed
	is_waiting_start = true

func accelerate(factor: float):
	if is_accelerated or not is_inside_tree(): return
	is_accelerated = true
	current_speed *= factor
	velocity = velocity.normalized() * current_speed

func reset_acceleration():
	if is_accelerated and is_inside_tree():
		is_accelerated = false
		current_speed /= 3.0
		velocity = velocity.normalized() * current_speed
		
func clamp_angle(vel: Vector2) -> Vector2:
	var min_angle = deg_to_rad(35.0) # Минимальный угол от горизонтали (35 градусов)
	var speed = vel.length()
	var angle = wrapf(vel.angle(), -PI, PI)
	var abs_angle = abs(angle)
	
	# Если мяч летит слишком горизонтально (близко к 0 или PI)
	if abs_angle < min_angle:
		angle = min_angle * sign(angle if angle != 0 else 1)
	elif abs_angle > PI - min_angle:
		angle = (PI - min_angle) * sign(angle)
		
	return Vector2(cos(angle), sin(angle)) * speed		
