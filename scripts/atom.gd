extends Node2D

const PHI = 1.618033988749894848204586834

@export var color: Color
@export var value: int
@export var ability: String


@export var movement_time: float
@export var appear_time: float
@export var total_merge_time: float
@export var movement_speed:float = 1
@export var spawn_chance: int
var velocity = Vector2(0,0)
var is_held_atom: bool
@onready var label = $Label
@onready var numLabel = $NumberLabel
@onready var sprite = $Sprite
@onready var grid = get_parent()
@onready var anim = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ability == "":
		label.text = grid.atom_label[value]
		numLabel.text = str(value)
	if UserSettings.show_atomic_number == false:
		numLabel.hide()

func move(x,y = 0, grid_movement = true, set_z_index = -2):
	var movement = create_tween()
	z_index = set_z_index
	if type_string(typeof(x)) == "Vector2":
		var gridPosition = grid.pixel_to_grid(position.x, position.y)
		var newGridPosition = Vector2(posmod(gridPosition.x + x.x, grid.width), posmod(gridPosition.y + x.y, grid.height))
		var newPixelPosition = grid.grid_to_pixel(newGridPosition.x, newGridPosition.y)
		movement.tween_property($".", "position", newPixelPosition, movement_time).set_trans(Tween.TRANS_CUBIC)
	else:
		
		if grid_movement: movement.tween_property($".", "position", grid.grid_to_pixel(x,y), movement_time).set_trans(Tween.TRANS_CUBIC)
		else: movement.tween_property($".", "position", Vector2(x,y), movement_time).set_trans(Tween.TRANS_CUBIC)
		
func appear():
	anim.play("appear")
	#var appear = create_tween()
	#appear.tween_property($".", "scale", grid.atom_scale, appear_time)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity*delta
