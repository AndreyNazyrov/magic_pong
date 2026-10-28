extends Node2D

var lives: int = 3
var score: int = 0
var total_blocks: int = 0
var goal_type: String = "destroy_all" 
var goal_target_color: String = "yellow" # Для "collect_color"
var goal_time: float = 0.0 # Для "survive_time"
var goal_timer: float = 0.0
var current_progress: int = 0


@onready var death_zone = $DeathZone
@onready var ball = $Ball
@onready var paddle = $Paddle
@onready var score_label = $HUDLayer/ScoreLabel
@onready var lives_label = $HUDLayer/LivesLabel
@onready var coins_label = $HUDLayer/CoinsLabel
@onready var hud_layer = $HUDLayer

var block_scene = preload("res://scenes/block.tscn")
var explosive_scene = preload("res://scenes/explosive_block.tscn")
var bonus_scene = preload("res://scenes/bonus.tscn")
var ball_scene_instance = preload("res://scenes/ball.tscn")

func _ready():
	randomize()
	SaveManager.load_game()
	
	# НАСТРОЙКА ЦЕЛИ (пока хардкод, потом будем читать из файла уровня)
	goal_type = "destroy_all" 
	# goal_type = "collect_color" # Раскомментируйте, чтобы протестировать сбор цвета
	# goal_target_color = "blue"
	
	death_zone.body_entered.connect(_on_death_zone_body_entered)
	ball.hit_paddle.connect(_on_ball_hit_paddle)
	update_ui()
	spawn_blocks()

func spawn_blocks():
	var cols = 12
	var rows = 6
	var block_width = 40
	var block_height = 20
	var gap_x = 18
	var gap_y = 8
	
	var total_width = cols * block_width + (cols - 1) * gap_x
	var start_x = (720 - total_width) / 2 + block_width / 2
	var start_y = 150
	var row_height = block_height + gap_y
	
	for row in range(rows):
		for col in range(cols):
			var roll = randf()
			var block
			
			if roll < 0.10:
				block = explosive_scene.instantiate()
				block.explode.connect(_on_explosive_block_exploded)
			elif roll < 0.25:
				block = block_scene.instantiate()
				block.is_strong = true
				block.hp = 2
				block.points = 20
			else:
				block = block_scene.instantiate()
			
			block.position = Vector2(
				start_x + col * (block_width + gap_x),
				start_y + row * row_height
			)
			add_child(block)
			block.destroyed.connect(_on_block_destroyed.bind(block.points, block.global_position))
			total_blocks += 1

func _on_block_destroyed(points: int, pos: Vector2):
	add_score(points)
	total_blocks -= 1
	
	# Проверка цели
	check_goal_progress()
	
	if randf() < 0.20:
		spawn_bonus(pos)
		
func check_goal_progress():
	match goal_type:
		"destroy_all":
			if total_blocks <= 0:
				win_level()
		"collect_color":
			# Здесь мы будем считать разбитые блоки нужного цвета
			# Но пока у нас нет разных цветов, оставим заглушку
			pass 		

func win_level():
	SaveManager.add_coins(10)
	SaveManager.unlock_level(2)
	get_tree().paused = true # <-- СТАВИМ ПАУЗУ
	if is_instance_valid(ball):
		ball.velocity = Vector2.ZERO
	$Victory.show_victory()

# --- БОНУСЫ ---
func spawn_bonus(pos: Vector2):
	var bonus = bonus_scene.instantiate()
	var all_types = ["grow", "chain", "multi", "freeze", "shrink", "heat"]
	bonus.bonus_type = all_types[randi() % all_types.size()]
	if bonus.bonus_type in ["shrink", "heat"]:
		bonus.has_cross = true
	bonus.position = pos
	add_child(bonus)

func apply_bonus(type: String):
	match type:
		"grow": apply_grow()
		"chain": paddle.is_charged = true
		"multi": apply_multi()
		"freeze": apply_freeze()
		"shrink": apply_shrink()
		"heat": apply_heat()

func apply_grow():
	paddle.scale.x = 1.5
	await get_tree().create_timer(10.0).timeout
	if is_instance_valid(paddle): paddle.scale.x = 1.0

func apply_shrink():
	paddle.scale.x = 0.6
	await get_tree().create_timer(10.0).timeout
	if is_instance_valid(paddle): paddle.scale.x = 1.0

func apply_freeze():
	var balls = get_balls()
	for b in balls:
		if is_instance_valid(b): b.can_move = false
	await get_tree().create_timer(2.0).timeout
	for b in balls:
		if is_instance_valid(b): b.can_move = true

func apply_heat():
	var balls = get_balls()
	for b in balls:
		if is_instance_valid(b):
			b.current_speed *= 1.5
			b.velocity = b.velocity.normalized() * b.current_speed
	await get_tree().create_timer(5.0).timeout
	for b in balls:
		if is_instance_valid(b):
			b.current_speed /= 1.5
			b.velocity = b.velocity.normalized() * b.current_speed

func apply_multi():
	var balls = get_balls()
	if balls.size() >= 5: return
		
	# Спавним только 1 дополнительный мяч
	var new_ball = ball_scene_instance.instantiate()
		
	# Спавним в безопасной зоне
	new_ball.position = Vector2(360, 900)
	new_ball.can_move = false
		
	var speed = 400.0
	if is_instance_valid(ball): speed = ball.current_speed
		
	var angle = randf_range(-PI/4, PI/4) - PI/2
	new_ball.velocity = Vector2(cos(angle), sin(angle)) * speed
		
	new_ball.hit_paddle.connect(_on_ball_hit_paddle)
	add_child.call_deferred(new_ball)

func destroy_random_nearby(center: Vector2, count: int):
	var radius = 150.0
	var candidates = []
	for child in get_children():
		if child is StaticBody2D and child.has_method("hit") and is_instance_valid(child):
			if child.global_position.distance_to(center) <= radius:
				candidates.append(child)
	candidates.shuffle()
	for i in range(min(count, candidates.size())):
		if is_instance_valid(candidates[i]): candidates[i].hit()

# --- ОБЫЧНАЯ ЛОГИКА ---
func _on_death_zone_body_entered(body):
	if body.is_in_group("balls"):
		body.queue_free()
		await get_tree().process_frame
		var remaining_balls = get_balls()
		if remaining_balls.size() == 0:
			lose_life()
			respawn_ball()
			
func _physics_process(delta):
	# Проверка: если мячей нет вообще, а игра идет — спавним
	if get_balls().size() == 0 and lives > 0:
		respawn_ball()
		
					

func get_balls() -> Array:
	var balls = []
	for child in get_children():
		if child is CharacterBody2D and child.is_in_group("balls"):
			balls.append(child)
	return balls

func _on_ball_hit_paddle(): add_score(1)

func lose_life():
	lives -= 1
	update_ui()
	for b in get_balls():
		if is_instance_valid(b): b.queue_free()
	if lives <= 0:
		game_over()

func game_over():
	get_tree().paused = true # <-- СТАВИМ ПАУЗУ
	if is_instance_valid(ball):
		ball.velocity = Vector2.ZERO
	$GameOver.show_game_over(score)

func add_score(points: int):
	score += points
	update_ui()

func update_ui():
	score_label.text = "Очки: " + str(score)
	lives_label.text = "❤️ " + str(lives)
	coins_label.text = "₽: " + str(SaveManager.coins)

func _on_explosive_block_exploded(explosion_pos: Vector2):
	var radius = 80.0
	var targets = []
	for child in get_children():
		# Проверяем, что это блок и он еще жив
		if child is StaticBody2D and child.has_method("hit") and is_instance_valid(child) and not child.is_queued_for_deletion():
			if child.global_position.distance_to(explosion_pos) <= radius:
				targets.append(child)
	
	for target in targets:
		if is_instance_valid(target) and not target.is_queued_for_deletion():
			target.hit()
			
	if is_instance_valid(ball) and ball.has_method("accelerate"):
		ball.accelerate(3.0)

func respawn_ball():
	var new_ball = ball_scene_instance.instantiate()
	new_ball.position = Vector2(360, 640)
	new_ball.hit_paddle.connect(_on_ball_hit_paddle)
	ball = new_ball 
	add_child.call_deferred(new_ball)
	
