extends Node2D

signal turnPassed

@onready var gridOffsetX = get_viewport_rect().size.x/2 - (200)
@onready var gridOffsetY = 125

var atomArray = []
<<<<<<< Updated upstream
@export var gridWidth = 5
@export var gridHeight = 5
var tileSize = 100
@onready var atomScene = load("res://scenes/atom.tscn")
@onready var selector = $Selector
var selectedAtom = 0
=======

var starting_atoms = [
	preload("res://scenes/atoms/hydrogen_atom.tscn"),
	preload("res://scenes/atoms/helium_atom.tscn") 
]

var possible_atoms = [
	preload("res://scenes/atoms/plus.tscn"),
	preload("res://scenes/atoms/hydrogen_atom.tscn"),
	preload("res://scenes/atoms/helium_atom.tscn"),
	preload("res://scenes/atoms/lithium_atom.tscn"),
	preload("res://scenes/atoms/beryllium_atom.tscn"),
	preload("res://scenes/atoms/boron_atom.tscn")
	]
	
var special_atoms = [
	preload("res://scenes/atoms/plus.tscn"),
	preload("res://scenes/atoms/minus.tscn")
]

var held_atom = random_atom()
var held_atom_instance
>>>>>>> Stashed changes
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in gridWidth:
		atomArray.append([])
		for j in gridHeight:
			atomArray[i].append(null)
	
<<<<<<< Updated upstream

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
=======
func merge_at(column, row):
	print("merge called")
	var storedValue = null
	var left = []
	var right = []
	var up = []
	var down = []
	var center = atomArray[column][row]
	var merge_time = center.total_merge_time

	for i in range(0,2):
		left.append(atomArray[posmod(column-(i+1),width)][row])
		right.append(atomArray[posmod(column+(i+1),width)][row])
		up.append(atomArray[column][posmod(row+(i+1),width)])
		down.append(atomArray[column][posmod(row-(i+1),width)])
	
	print(left)
	#check if left and right neighboring atoms exist and aren't empty spaces
	for i in range(0, 2):
		if (left[i] != null && right[i] != null) && (left[i].value == right[i].value):
				#storedValue is the value that the plus atom will end up being by the end of the merging process
				if storedValue == null:
					storedValue = left[i].value
				else:
					storedValue += 1
				#delete left, right, and center atom
				left[i].z_index = -1
				right[i].z_index = -1
				left[i].move(column, row)
				right[i].move(column, row)
				await get_tree().create_timer(merge_time).timeout
				delete_atom(left[i])
				delete_atom(right[i])
				delete_atom(column, row)
				#spawn new atom with proper value
				spawn_atom(column, row, possible_atoms[storedValue+1])
				print(i) 
		else:
			break
	for i in range(0, 2):
		if (down[i] != null && up[i] != null) && (down[i].value == up[i].value):
				#storedValue is the value that the plus atom will end up being by the end of the merging process
				
				if storedValue == null:
					storedValue = down[i].value
				else:
					storedValue += 1
				#delete left, right, and center atom
				down[i].z_index = -1
				up[i].z_index = -1
				down[i].move(column, row)
				up[i].move(column, row)
				await get_tree().create_timer(merge_time).timeout
				delete_atom(up[i])
				delete_atom(down[i])
				delete_atom(column, row)
				#spawn new atom with proper value
				spawn_atom(column, row, possible_atoms[storedValue+1])

func random_atom():
	var rand = floor(randf_range(0,2))
	var atom = possible_atoms[rand]
	return atom

func fill_array():
	for i in width:
		for j in height:
			#choose a random number and store it
			var rand = floor(randf_range(0,starting_atoms.size()))
			#Instance piece from array
			if randi_range(1, 2) == 1:
				var atom = starting_atoms[rand].instantiate()
				add_child(atom)
				atom.position = grid_to_pixel(i, j)
				atom.scale = Vector2(atom_scale, atom_scale)
				atomArray[i][j] = atom
				
func grid_to_pixel(column, row):
	var new_x = x_start + offset*column
	var new_y = y_start - offset*row
	return Vector2(new_x, new_y);

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start)/offset)
	var new_y = round((pixel_y - y_start)/-offset)
	return Vector2(new_x,new_y)

# SHOULD ONLY ACCEPT PACKED / PRELOADED SCENES, do not pass in an already instanced scene
# UPDATE: can accept both uninstanced and instanced scenes :) all is well
func spawn_atom(x,y, type):
	var atom
	if type == null:
		delete_atom(x,y)
		return
		#checks if the scene has already been instantiated
	if type.has_method("instantiate"):
		atom = type.instantiate()
	else:
		atom = possible_atoms[type.value].instantiate()
	add_child(atom)
	atom.position = grid_to_pixel(x, y)
	atom.scale = Vector2(atom_scale, atom_scale)
	atomArray[x][y] = atom

func move_atom(x1,y1, x2,y2):
	var atom = atomArray[x1][y1]
	delete_atom(x2,y2)
	spawn_atom(x2,y2, atom)
	delete_atom(x1,y1)

func atom_select():
	if Input.is_action_just_pressed("select_plus"):
		cycle_held_atom(possible_atoms[0])
	if Input.is_action_just_pressed("select_hydrogen"):
		cycle_held_atom(possible_atoms[1])
	if Input.is_action_just_pressed("select_helium"):
		cycle_held_atom(special_atoms[1])

func erase_input():
	if Input.is_action_pressed("ui_erase"):
		var grid_position = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
		if grid_position.x >= 0 && grid_position.x < width && grid_position.y >= 0 && grid_position.y < width:
			if atomArray[grid_position.x][grid_position.y] != null:
				#delete last held atom instance
				var x = grid_position.x
				var y = grid_position.y
				delete_atom(x,y)

#Can accept an atom from atomArray OR coordinates in the form of an int or a float.
#WARNING: If passing in an atom instead of coordinates, if the atom has been freed, the game will bug out.
func delete_atom(x,y = null):
	if typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT:
		if atomArray[x][y] != null:
			atomArray[x][y].queue_free()
			atomArray[x][y] = null
	else:
		if x != null:
			x.queue_free()
			x = null

func cycle_held_atom(atom):
	if held_atom_instance.has_method("queue_free"):
		held_atom_instance.queue_free()
	if atom.has_method("instantiate"):
		held_atom = atom
	else:
		held_atom = possible_atoms[atom.value]
	held_atom_instance = held_atom.instantiate()
	add_child(held_atom_instance)
	held_atom_instance.position = Vector2(288,900)
	held_atom_instance.scale = Vector2(atom_scale, atom_scale)
	pass

func touch_input():
	
	if Input.is_action_just_released("ui_touch"):
		var grid_position = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
		if grid_position.x >= 0 && grid_position.x < width && grid_position.y >= 0 && grid_position.y < width:
			var x = grid_position.x
			var y = grid_position.y
			
			if held_atom_instance.ability == "minus":
				if atomArray[x][y] != null:
					cycle_held_atom(atomArray[x][y])
					delete_atom(atomArray[x][y])
			if atomArray[x][y] == null:
				#delete last held atom instance
				held_atom_instance.queue_free()
				
				spawn_atom(x,y, held_atom)
				#update held atom with random atom (random atom returns an atom instance of 
				cycle_held_atom(random_atom())
				grid_logic()
	
	

				
func grid_logic():
	for i in width:
		for j in height:
			if atomArray[i][j] != null && atomArray[i][j].ability == "plus":
				merge_at(i,j)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	touch_input()
	erase_input()
	atom_select()
	
>>>>>>> Stashed changes
