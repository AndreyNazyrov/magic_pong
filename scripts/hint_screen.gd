extends CanvasLayer

@onready var text_label = $TextLabel

func _ready():
	visible = false
	$Bg.gui_input.connect(_on_input)

func show_hint(text: String):
	text_label.text = text
	visible = true
	get_tree().paused = true

func _on_input(event):
	if event is InputEventMouseButton and event.pressed:
		hide_hint()
	elif event is InputEventScreenTouch and event.pressed:
		hide_hint()

func hide_hint():
	visible = false
	get_tree().paused = false
