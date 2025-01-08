extends Node2D

var gridPosition = Vector2(0,0)
@onready var grid = get_parent()
@onready var gridWidth = get_parent().gridWidth
@onready var gridHeight = get_parent().gridHeight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scale = Vector2(20/gridWidth,20/gridHeight)
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var gridOffsetX = get_viewport_rect().size.x/2 - 200
	var gridOffsetY = 125
	if Input.is_action_just_pressed("move_right"):
		gridPosition.x += 1
	if Input.is_action_just_pressed("move_left"):
		gridPosition.x += -1
	if Input.is_action_just_pressed("move_up"):
		gridPosition.y += -1
	if Input.is_action_just_pressed("move_down"):
		gridPosition.y += 1
	
	gridPosition.x = posmod(gridPosition.x, get_parent().gridWidth)
	gridPosition.y = posmod(gridPosition.y, get_parent().gridHeight)
	
	position = Vector2(gridPosition.x*500/grid.gridWidth + grid.gridOffsetX, gridPosition.y*500/grid.gridHeight + grid.gridOffsetY)
