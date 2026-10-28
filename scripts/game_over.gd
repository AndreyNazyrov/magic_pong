extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var restart_button = $RestartButton

func _ready():
	# Скрываем экран по умолчанию
	visible = false
	# Подключаем кнопку
	restart_button.pressed.connect(_on_restart_pressed)

func show_game_over(final_score: int):
	score_label.text = "Очки: " + str(final_score)
	visible = true

func _on_restart_pressed():
	get_tree().paused = false
	visible = false
	get_tree().reload_current_scene()
