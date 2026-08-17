extends Control
@onready var scoreCounter = $Score
@onready var pauseButton = $Pause
@onready var pauseMenu = $PauseMenu
@onready var resumeButton = $PauseMenu/HBoxContainer/Resume
@onready var powerUpContainer = $PowerUpContainer
var score = 0
var paused = false

func _ready():
	update_score()
	pauseButton.pressed.connect(pauseMenu.pause)
	pauseButton.pressed.connect(pauseButton.pause)
	resumeButton.pressed.connect(pauseMenu.resume)
	resumeButton.pressed.connect(pauseButton.resume)

func add_score(value):
	score += value
	update_score()

func update_score():
	scoreCounter.text = str(score)
