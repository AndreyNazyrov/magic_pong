extends Control

func _ready():
	SaveManager.load_game()
	$PlayBtn.pressed.connect(_on_play_pressed)
	$ExitBtn.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	# Переходим на экран выбора уровней
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_exit_pressed():
	get_tree().quit()
