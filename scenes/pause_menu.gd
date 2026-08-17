extends Control
var paused = false

func _ready() -> void:
	hide()

func pause():
	show()

func resume():
	hide()
