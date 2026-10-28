extends Area2D

@export var fall_speed: float = 200.0
var bonus_type: String = "grow"
var has_cross: bool = false # Рисуем крестик или нет

@onready var visual = $Visual

func _ready():
	# Цветовая палитра для всех типов (и обычных, и анти)
	match bonus_type:
		"grow": visual.color = Color("22c55e")    # Зеленый (Рост)
		"shrink": visual.color = Color("22c55e")  # Зеленый (Сжатие - анти)
		"chain": visual.color = Color("fbbf24")   # Желтый (Молния)
		"multi": visual.color = Color("a855f7")   # Фиолетовый (Мультимяч)
		"freeze": visual.color = Color("e5e7eb")  # Белый (Заморозка)
		"heat": visual.color = Color("e5e7eb")    # Белый (Жар - анти)
		
	# Создаем круг
	var points = PackedVector2Array()
	for i in range(16):
		var angle = i * (2 * PI / 16)
		points.append(Vector2(cos(angle), sin(angle)) * 15)
	visual.polygon = points
	
	# Если есть крестик — рисуем
	if has_cross:
		draw_cross()
		
	body_entered.connect(_on_body_entered)

func draw_cross():
	var cross = Polygon2D.new()
	cross.polygon = PackedVector2Array([
		Vector2(-3, -10), Vector2(3, -10), Vector2(3, -3), Vector2(10, -3),
		Vector2(10, 3), Vector2(3, 3), Vector2(3, 10), Vector2(-3, 10),
		Vector2(-3, 3), Vector2(-10, 3), Vector2(-10, -3), Vector2(-3, -3)
	])
	cross.color = Color("000000")
	cross.z_index = 1
	add_child(cross)

func _process(delta):
	position.y += fall_speed * delta
	if position.y > 1300:
		queue_free()

func _on_body_entered(body):
	if body.name == "Paddle":
		get_parent().apply_bonus(bonus_type)
		queue_free()
