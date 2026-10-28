extends CharacterBody2D

signal hit_paddle

@export var base_speed: float = 400.0
@export var speed_increase: float = 10.0
@export var min_angle_deg: float = 20.0

var current_speed: float = 400.0
var is_accelerated: bool = false
var stuck_timer: float = 0.0
var has_chain: bool = false
var can_move: bool = false # Флаг для безопасного спавна

func _ready():
	add_to_group("balls")
	randomize()
	
	# Создаем визуал (круг)
	var points = PackedVector2Array()
	var radius = 15
	for i in range(16):
		var angle = i * (2 * PI / 16)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	$Visual.polygon = points
	$Visual.color = Color("a78bfa")
	
	# Ждем 2 кадра, чтобы физика "увидела" мяч
	await get_tree().process_frame
	await get_tree().process_frame
	can_move = true
	
	reset_ball()

func reset_ball():
	# Стартовая позиция — центр экрана
	position = Vector2(360, 640)
	
	# Сброс состояний
	is_accelerated = false
	stuck_timer = 0.0
	has_chain = false
	current_speed = base_speed
	
	# Случайное направление
	var angle = randf_range(-PI / 4, PI / 4)
	if randi() % 2 == 0:
		angle += PI
		
	velocity = Vector2(cos(angle), sin(angle)) * current_speed

func _physics_process(delta):
	if not can_move:
		return # Мяч стоит на месте (заморозка или спавн)
		
	# Проверка на вылет за экран (если проскочил сквозь стену)
	if position.y > 1350 or position.y < -50 or position.x < -50 or position.x > 770:
		reset_ball()
		return
			   		
		 
		
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		
		# 1. Посох
		if collider.name == "Paddle":
			hit_paddle.emit()
			reset_acceleration()
			
			# Забираем заряд молнии
			if collider.is_charged:
				has_chain = true
				collider.is_charged = false
			
			# --- ФИЗИКА ОТСКОКА ОТ ПОСОХА ---
			var normal = collision.get_normal()
			var new_velocity = velocity.bounce(normal)
			
			var paddle = collider
			var paddle_half = 80.0
			var offset = (global_position.x - paddle.global_position.x) / paddle_half
			offset = clamp(offset, -1.0, 1.0)
			
			# Если удар пришелся сверху (normal.y < 0), добавляем угол
			if normal.y < 0:
				var angle_offset = offset * deg_to_rad(60)
				new_velocity.x += sin(angle_offset) * current_speed
				new_velocity.y = -abs(new_velocity.y) # Гарантируем полет вверх
			
			# Нормализуем и применяем скорость
			velocity = new_velocity.normalized() * current_speed
			velocity = clamp_angle(velocity)
			return # Выходим, скорость уже задана
			
		# 2. Блоки
		elif collider is StaticBody2D and collider.has_method("hit"):
			collider.hit()
			
			# Если есть заряд молнии — бьем по соседям
			if has_chain:
				has_chain = false
				var pos = collider.global_position
				get_parent().destroy_random_nearby(pos, 3)
				
				if not is_instance_valid(self):
					return
		
		# 3. Стены (и все остальное)
		velocity = velocity.bounce(collision.get_normal())
		current_speed += speed_increase
		velocity = velocity.normalized() * current_speed
		velocity = clamp_angle(velocity)
		
		# Защита от застревания
		stuck_timer += delta
		if stuck_timer > 1.5:
			stuck_timer = 0.0
			reset_ball()
			return
	else:
		stuck_timer = 0.0

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
	var min_angle = deg_to_rad(min_angle_deg)
	var speed = vel.length()
	var angle = wrapf(vel.angle(), -PI, PI)
	var abs_angle = abs(angle)
	
	if abs_angle < min_angle:
		@warning_ignore("incompatible_ternary")
		angle = min_angle * sign(angle if angle != 0 else 1)
	elif abs_angle > PI - min_angle:
		angle = (PI - min_angle) * sign(angle)
		
	return Vector2(cos(angle), sin(angle)) * speed
