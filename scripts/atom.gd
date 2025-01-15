<<<<<<< Updated upstream
extends CharacterBody2D
@onready var textLabel = $RichTextLabel
@onready var value
@export var ability = null
@onready var grid = get_parent()
@onready var atomArray = get_parent().atomArray

var gridOffsetX
var gridPosition = Vector2(0,0)
func _physics_process(delta: float) -> void:
	checkGrid()
=======
extends Node2D

const PHI = 1.618033988749894848204586834

@export var color: Color
@export var value: int
@export var ability: String
@onready var label = $Label
@onready var sprite = $Sprite
@onready var grid = get_parent()
@onready var anim = $AnimationPlayer
@export var movement_time: float
@export var total_merge_time: float
@export var movement_speed:float
var velocity = Vector2(0,0)
>>>>>>> Stashed changes


func _ready() -> void:
<<<<<<< Updated upstream
	get_parent().turnPassed.connect(self.on_turn_passed)
	position = Vector2(gridPosition.x*500/grid.gridWidth + grid.gridOffsetX, gridPosition.y*500/grid.gridHeight + grid.gridOffsetY)
=======
	
	if ability == null:
		label.text = grid.atom_label[value]
		sprite.self_modulate = Color(0,1,0)
	appear()
	
	
func move(x,y):
	#var original_position = position
	#velocity = direction*(grid.offset*movement_speed)
	#await get_tree().create_timer(1/movement_speed).timeout
	#velocity = Vector2(0,0)
	#position = original_position + direction*grid.offset
	
	var movement = create_tween()
	movement.tween_property($".", "position", grid.grid_to_pixel(x,y), movement_time)
	pass
>>>>>>> Stashed changes

func on_turn_passed():
	var x = gridPosition.x
	var y = gridPosition.y
	if ability == "+":
		if gridPosition.x != 0 && gridPosition.x != grid.gridWidth-1:
			if atomArray[x+1][y] && atomArray[x-1][y]:
				if atomArray[x+1][y].value == atomArray[x-1][y].value:
					var newValue = max(value, atomArray[x+1][y].value) + 1
					value = newValue
					atomArray[x+1][y] = null
					atomArray[x-1][y] = null
					ability = null
		if gridPosition.y != 0 && gridPosition.y != grid.gridWidth-1:
			if atomArray[x][y+1] && atomArray[x][y-1]:
				if atomArray[x][y+1].value == atomArray[x][y-1].value:
					var newValue = max(value, atomArray[x][y+1].value) + 1
					value = newValue
					atomArray[x][y+1] = null
					atomArray[x][y-1] = null
					ability = null
			
	if !ability:
		textLabel.text = str(value)
	elif ability == "+": 
		textLabel.text = "+"	
	checkGrid()
	print(gridPosition.x)
	
func checkGrid():
	
	
	if atomArray[gridPosition.x][gridPosition.y] == null:
		queue_free()
	
