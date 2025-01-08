extends Node2D

signal turnPassed

@onready var gridOffsetX = get_viewport_rect().size.x/2 - (200)
@onready var gridOffsetY = 125

var atomArray = []
@export var gridWidth = 5
@export var gridHeight = 5
var tileSize = 100
@onready var atomScene = load("res://scenes/atom.tscn")
@onready var selector = $Selector
var selectedAtom = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in gridWidth:
		atomArray.append([])
		for j in gridHeight:
			atomArray[i].append(null)
	

func fillArray() -> void:
	for i in gridWidth:
		atomArray.append([])
		for j in gridHeight:
			var atomInstance = atomScene.instantiate()
			atomInstance.position = Vector2(i*500/gridWidth + gridOffsetX, j*500/gridHeight + gridOffsetY)
			atomInstance.scale = Vector2(20/gridWidth,20/gridHeight)
			atomInstance.value = 0
			add_child(atomInstance)
			atomArray[i].append(atomInstance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var gridX = selector.gridPosition.x
	var gridY = selector.gridPosition.y
	if Input.is_action_just_pressed("Add Atom"):
		spawnAtom(gridX, gridY)
	
func spawnAtom(x: int, y: int, atom = selectedAtom):
	var atomInstance = atomScene.instantiate()
	atomInstance.scale = Vector2(20/gridWidth,20/gridHeight)
	atomInstance.value = 1
	atomInstance.ability = "+"
	atomInstance.gridPosition = Vector2(x,y)
	add_child(atomInstance)
	atomArray[x][y] = atomInstance
	turnPassed.emit()	
