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
	
	]
	
var special_atoms = [
	preload("res://scenes/atoms/plus.tscn"),
	preload("res://scenes/atoms/minus.tscn")
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
	
	var storedValue = null
	
	var center = atomArray[column][row]
	
	var left = atomArray[posmod(column-1,width)][row]
	var right = atomArray[posmod(column+1,width)][row]
	
	var left2 = atomArray[posmod(column-2,width)][row]
	var right2 = atomArray[posmod(column+2,width)][row]
	
	var up = atomArray[column][posmod(row+1,width)]
	var down = atomArray[column][posmod(row-1,width)]
	
	var up2 = atomArray[column][posmod(row+2,width)]
	var down2 = atomArray[column][posmod(row-2,width)]
	
	#check if left and right neighboring atoms exist and aren't empty spaces
	if left != null && right != null:
		if left.value == right.value:
			#storedValue is the value that the plus atom will end up being by the end of the merging process
			if center.ability == "plus" && center != null:
				storedValue = left.value
			else:
				storedValue = center.value
			#delete left, right, and center atom

			delete_atom(posmod(column-1,width), row)
			delete_atom(posmod(column+1,width), row)
			delete_atom(column, row)
			#spawn new atom with proper value
			spawn_atom(column, row, possible_atoms[storedValue+1])
			
			#pull all atoms in row towards plus atom
			move_atom(posmod(column-2, width), row, posmod(column-1,width), row)
			move_atom(posmod(column+2, width), row, posmod(column+1,width), row)
			merge_at(column, row)
			return
			
			
	if down != null && up != null:
		if down.value == up.value:
			if center.ability == "plus" && center != null:
				storedValue = up.value
			else:
				storedValue = center.value
			#delete left and right atom, then the plus itself
			delete_atom(down)
			delete_atom(up)
			delete_atom(column, row)
			#replace plus with the final value
			spawn_atom(column, row, possible_atoms[storedValue+1])
			#MAKE SURE TO ADD CHECK FOR NULL INSTANCE IN ATOM ARRAY
			move_atom(column, posmod(row+2, height), column, posmod(row+1, height))
			move_atom(column, posmod(row-2, height), column, posmod(row-1, height))
			merge_at(column, row)
			return
	
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
	if atomArray[x][y].ability == "plus":
		merge_at(x,y)
		print(atomArray)

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

				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	touch_input()
	erase_input()
	atom_select()
	for i in width:
		for j in height:
			if atomArray[i][j] != null && atomArray[i][j].ability == "plus":
				merge_at(i,j)
