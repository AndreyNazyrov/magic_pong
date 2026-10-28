extends Control

func _ready():
	$BackBtn.pressed.connect(_on_back_pressed)
	create_level_buttons()

func create_level_buttons():
	var grid = find_child("GridContainer")
	# Удаляем старые кнопки (если есть)
	for child in grid.get_children():
		child.queue_free()
		
	# Создаем 19 уровней + босс (20)
	for i in range(1, 21):
		var btn = Button.new()
		btn.text = str(i)
		btn.custom_minimum_size = Vector2(100, 100)
		
		# Если уровень заблокирован — делаем его неактивным
		if i > SaveManager.unlocked_levels:
			btn.disabled = true
			btn.modulate = Color(1, 1, 1, 0.3) # Прозрачный
			
		btn.pressed.connect(_on_level_pressed.bind(i))
		grid.add_child(btn)

func _on_level_pressed(level: int):
	# Переходим в игру (в будущем будем передавать номер уровня)
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
