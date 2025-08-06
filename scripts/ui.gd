extends Control
@onready var scoreCounter = $Score
@onready var pauseButton = $Pause
@onready var powerUpContainer = $PowerUpContainer
var score = 0
var paused = false

func _ready():
	update_score()

func add_score(value):
	score += value
	update_score()

func update_score():
	scoreCounter.text = str(score)
