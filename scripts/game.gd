extends Node2D

var lives: int = 3
var score: int = 0
var total_blocks: int = 0
var goal_type: String = "destroy_all" 
var level_config: Dictionary = {}

@onready var death_zone = $DeathZone
@onready var ball = $Ball
@onready var paddle = $Paddle
@onready var score_label = $HUDLayer/ScoreLabel
@onready var lives_label = $HUDLayer/LivesLabel
@onready var coins_label = $HUDLayer/CoinsLabel
@onready var hint_screen = $HintScreen

var block_scene = preload("res://scenes/block.tscn")
var big_block_scene = preload("res://scenes/big_block.tscn")
var explosive_scene = preload("res://scenes/explosive_block.tscn")
var bonus_scene = preload("res://scenes/bonus.tscn")
var ball_scene_instance = preload("res://scenes/ball.tscn")
var level_data_script = preload("res://scripts/level_data.gd")

func _ready():
	randomize()
	SaveManager.load_game()
	$HUDLayer/MenuButton.pressed.connect(_on_menu_button_pressed)
	
	# Загружаем конфиг уровня
	var ld = level_data_script.new()
	level_config = ld.levels.get(SaveManager.current_level, {"goal": "destroy_all", "blocks": "default"})
	goal_type = level_config.get("goal", "destroy_all")
	
	death_zone.body_entered.connect(_on_death_zone_body_entered)
	ball.hit_paddle.connect(_on_ball_hit_paddle)
	ball.paddle_ref = paddle
	
	update_ui()
	spawn_blocks()
	
	if level_config.has("text"):
		hint_screen.show_hint(level_config["text"])

func spawn_blocks():
	if level_config.has("blocks") and level_config["blocks"] is Array:
		for b in level_config["blocks"]:
			var block
			if b["type"] == "big": block = big_block_scene.instantiate()
			elif b["type"] == "explosive": 
				block = explosive_scene.instantiate()
				block.explode.connect(_on_explosive_block_exploded)
			elif b["type"] == "strong":
				block = block_scene.instantiate()
				block.is_strong = true
				block.hp = 2
				block.points = 20
			else: block = block_scene.instantiate()
				
			block.position = b["pos"]
			add_child(block)
			block.destroyed.connect(_on_block_destroyed.bind(block.points, block.global_position))
			total_blocks += 1
	else:
		# Стандартная сетка
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
				
				block.position = Vector2(start_x + col * (block_width + gap_x), start_y + row * row_height)
				add_child(block)
				block.destroyed.connect(_on_block_destroyed.bind(block.points, block.global_position))
				total_blocks += 1

func _on_block_destroyed(points: int, pos: Vector2):
	add_score(points)
	total_blocks -= 1
	
	# 1. Случайный шанс из конфига
	var chance = level_config.get("bonus_chance", 0.0)
	if chance > 0 and randf() < chance:
		spawn_bonus(pos)
		
	# 2. Гарантированный бонус (при последнем блоке)
	if total_blocks == 0 and level_config.has("guaranteed_bonus"):
		spawn_specific_bonus(pos, level_config["guaranteed_bonus"])
		
	check_goal_progress()

func spawn_bonus(pos: Vector2):
	var allowed = level_config.get("bonuses", [])
	if allowed.size() == 0: return 
	
	var bonus = bonus_scene.instantiate()
	bonus.bonus_type = allowed[randi() % allowed.size()]
	if bonus.bonus_type in ["shrink", "heat"]: bonus.has_cross = true
	bonus.position = pos
	add_child(bonus)

func spawn_specific_bonus(pos: Vector2, type: String):
	var bonus = bonus_scene.instantiate()
	bonus.bonus_type = type
	if type in ["shrink", "heat"]: bonus.has_cross = true
	bonus.position = pos
	add_child(bonus)

func check_goal_progress():
	if goal_type == "destroy_all" and total_blocks <= 0:
		win_level()

func win_level():
	SaveManager.add_coins(10)
	SaveManager.unlock_level(SaveManager.current_level + 1)
	get_tree().paused = true
	if is_instance_valid(ball):
		ball.velocity = Vector2.ZERO
	$Victory.show_victory()

# --- БОНУСЫ (Логика) ---
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
		if is_instance_valid(b) and b.is_inside_tree():
			b.current_speed /= 1.5
			b.velocity = b.velocity.normalized() * b.current_speed

func apply_multi():
	var balls = get_balls()
	if balls.size() >= 5: return
	var new_ball = ball_scene_instance.instantiate()
	new_ball.position = paddle.position + Vector2(0, -50)
	new_ball.can_move = false
	new_ball.is_waiting_start = false
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
		if child is StaticBody2D and child.has_method("hit") and is_instance_valid(child) and not child.is_queued_for_deletion():
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
	get_tree().paused = true
	if is_instance_valid(ball): ball.velocity = Vector2.ZERO
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
	new_ball.position = paddle.position + Vector2(0, -50)
	new_ball.paddle_ref = paddle
	new_ball.hit_paddle.connect(_on_ball_hit_paddle)
	ball = new_ball 
	add_child.call_deferred(new_ball)

func _on_menu_button_pressed():
	get_tree().paused = false  
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
