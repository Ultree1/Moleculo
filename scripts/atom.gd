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


func _ready() -> void:
	get_parent().turnPassed.connect(self.on_turn_passed)
	position = Vector2(gridPosition.x*500/grid.gridWidth + grid.gridOffsetX, gridPosition.y*500/grid.gridHeight + grid.gridOffsetY)

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
	
