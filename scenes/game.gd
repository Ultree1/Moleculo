extends Node2D
@onready var grid = $grid
@onready var UI = $UI
@onready var powerUpContainer = UI.powerUpContainer
func _ready():
	grid.addScore.connect(UI.add_score)
	for i in powerUpContainer.get_child_count():
		var powerUp = powerUpContainer.get_children()[i]
		grid.passTurn.connect(powerUp.turn_passed)
		powerUp.usePowerUp.connect(grid.usePowerUp)
		InputHandler.swipe.connect(grid.receive_swipe)
