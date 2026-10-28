extends CanvasLayer

func _ready():
	visible = false
	$ContinueButton.pressed.connect(_on_continue_pressed)

func show_victory():
	visible = true

func _on_continue_pressed():
	get_tree().paused = false
	visible = false
	# Возвращаемся в меню выбора уровней
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
