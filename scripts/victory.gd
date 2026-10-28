extends CanvasLayer

func _ready():
	visible = false
	$ContinueButton.pressed.connect(_on_continue_pressed)

func show_victory():
	visible = true

func _on_continue_pressed():
	get_tree().paused = false
	visible = false
	get_tree().reload_current_scene() # Перезапуск текущего уровня
