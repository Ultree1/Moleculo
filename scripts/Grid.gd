extends Node2D

#Grid variables
@export var width:int
@export var height:int
@export var x_start:int 
@export var y_start:int
@export var offset:int
@export var atom_scale:float

var atom_label = [
	"?", "H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne", "Na", "Mg", "Al", "Si", "P", "S", "Cl", "Ar", "K", "Ca", "Sc", "Ti", "V", "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn", "Ga", "Ge", "As", "Se", "Br", "Kr", "Rb", "Sr", "Y", "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd", "In", "Sn", "Sb", "I", "Te", "Xe", "Cs", "Ba", "La", "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu", "Hf", "Ta", "W", "Re", "Os", "Ir", "Pt", "Au", "Hg", "Tl", "Pb", "Bi", "Po", "At", "Rn", "Fr", "Ra", "Ac", "Th", "Pa", "U", "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm", "Md", "No", "Lr", "Rf", "Db", "Sg", "Bh", "Hs", "Mt", "Ds", "Rg", "Cn", "Nh", "Fl", "Mc", "Lv", "Ts", "Og"
]

var atomArray = []

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
	preload("res://scenes/atoms/boron_atom.tscn"),
	preload("res://scenes/atoms/carbon_atom.tscn"),
	preload("res://scenes/atoms/nitrogen_atom.tscn"),
	preload("res://scenes/atoms/oxygen_atom.tscn")
	]
	
var special_atoms = [
	preload("res://scenes/atoms/plus.tscn"),
	preload("res://scenes/atoms/minus.tscn"),
	preload("res://scenes/atoms/neutrino.tscn")
]

var held_atom = random_atom()
var held_atom_instance
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	held_atom = random_atom()
	held_atom_instance = held_atom.instantiate()
	add_child(held_atom_instance)
	held_atom_instance.position = Vector2(288,900)
	held_atom_instance.scale = Vector2(0, 0)
	atomArray = make_2d_array()
	fill_array()
	print(atomArray)

func make_2d_array():
	var array = []
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array
	
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
					if left[i].value >= atomArray[column][row].value:
						storedValue = left[i].value + 1
					else:
						storedValue += 1
				#delete left, right, and center atom
				left[i].z_index = -i
				right[i].z_index = -i
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
					if up[i].value >= atomArray[column][row].value:
						storedValue = down[i].value + 1
					else:
						storedValue += 1
				#delete left, right, and center atom
				down[i].z_index = -i
				up[i].z_index = -i
				down[i].move(column, row)
				up[i].move(column, row)
				await get_tree().create_timer(merge_time).timeout
				delete_atom(up[i])
				delete_atom(down[i])
				delete_atom(column, row)
				#spawn new atom with proper value
				spawn_atom(column, row, possible_atoms[storedValue+1])
				
		else:
			break
	if storedValue != null:
		grid_logic()

	
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
		pass
	if Input.is_action_just_pressed("select_hydrogen"):
		cycle_held_atom(possible_atoms[1])
	if Input.is_action_just_pressed("select_helium"):
		cycle_held_atom(possible_atoms[2])
	if Input.is_action_just_pressed("key_q"):
		cycle_held_atom(possible_atoms[0])
	if Input.is_action_just_pressed("key_w"):
		cycle_held_atom(special_atoms[1])
	if Input.is_action_just_pressed("key_e"):
		cycle_held_atom(special_atoms[2])
	if Input.is_action_just_pressed("key_r"):
		cycle_held_atom(possible_atoms[0])

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
			if held_atom_instance.ability == "multiply":
				if atomArray[x][y] != null:
					cycle_held_atom(atomArray[x][y])
			if atomArray[x][y] == null && (held_atom_instance.ability == "" or held_atom_instance.ability == "plus"):
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
