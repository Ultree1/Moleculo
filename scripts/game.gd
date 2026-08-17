extends Node2D
@onready var grid = $grid
@onready var UI = $UI
@onready var pauseButton = $UI/Pause
@onready var resumeButton = $UI/PauseMenu/HBoxContainer/Resume
@onready var powerUpContainer = UI.powerUpContainer
func _ready():
	grid.addScore.connect(UI.add_score)
	pauseButton.pressed.connect(grid.pause)
	resumeButton.pressed.connect(grid.resume)
	
	for i in powerUpContainer.get_child_count():
		var powerUp = powerUpContainer.get_children()[i]
		grid.passTurn.connect(powerUp.turn_passed)
		grid.atomMerged.connect(powerUp.atom_merged)
		powerUp.usePowerUp.connect(grid.usePowerUp)
		InputHandler.swipe.connect(grid.receive_swipe)
		
