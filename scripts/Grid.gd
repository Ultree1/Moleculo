extends Node2D

#Grid variables
@export var width:int
@export var height:int
@export var x_start:int 
@export var y_start:int
@export var offset:int
@export var atom_scale:float
@export var next_atom_scale: float
@export var total_merge_time: float

#Stores all label text for each atom type
var atom_label = [
	"?", "H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne", "Na", "Mg", "Al", "Si", "P", "S", "Cl", "Ar", "K", "Ca", "Sc", "Ti", "V", "Cr", "Mn", "Fe", "Co", "Ni", "Cu", "Zn", "Ga", "Ge", "As", "Se", "Br", "Kr", "Rb", "Sr", "Y", "Zr", "Nb", "Mo", "Tc", "Ru", "Rh", "Pd", "Ag", "Cd", "In", "Sn", "Sb", "I", "Te", "Xe", "Cs", "Ba", "La", "Ce", "Pr", "Nd", "Pm", "Sm", "Eu", "Gd", "Tb", "Dy", "Ho", "Er", "Tm", "Yb", "Lu", "Hf", "Ta", "W", "Re", "Os", "Ir", "Pt", "Au", "Hg", "Tl", "Pb", "Bi", "Po", "At", "Rn", "Fr", "Ra", "Ac", "Th", "Pa", "U", "Np", "Pu", "Am", "Cm", "Bk", "Cf", "Es", "Fm", "Md", "No", "Lr", "Rf", "Db", "Sg", "Bh", "Hs", "Mt", "Ds", "Rg", "Cn", "Nh", "Fl", "Mc", "Lv", "Ts", "Og"
]
#Stores the colors for each atom type (for the first few atoms at least)
var atom_color = []
#Stores the live game board
var atomArray = []

var starting_atoms = [
	preload("res://scenes/atoms/hydrogen_atom.tscn"),
	preload("res://scenes/atoms/helium_atom.tscn") 
]

var possible_atoms = [
	preload("res://scenes/special atoms/plus.tscn"),
	preload("res://scenes/atoms/hydrogen_atom.tscn"),
	preload("res://scenes/atoms/helium_atom.tscn"),
	preload("res://scenes/atoms/lithium_atom.tscn"),
	preload("res://scenes/atoms/beryllium_atom.tscn"),
	preload("res://scenes/atoms/boron_atom.tscn"),
	preload("res://scenes/atoms/carbon_atom.tscn"),
	preload("res://scenes/atoms/nitrogen_atom.tscn"),
	preload("res://scenes/atoms/oxygen_atom.tscn"),
	preload("res://scenes/atoms/fluorine_atom.tscn"),
	preload("res://scenes/atoms/neon_atom.tscn"),
	preload("res://scenes/atoms/sodium_atom.tscn"),
	preload("res://scenes/atoms/magnesium_atom.tscn"),
	preload("res://scenes/atoms/aluminum_atom.tscn"),
	preload("res://scenes/atoms/silicon_atom.tscn"),
	preload("res://scenes/atoms/phosphorus_atom.tscn"),
	preload("res://scenes/atoms/sulphur_atom.tscn"),
	preload("res://scenes/atoms/chlorine_atom.tscn"),
	preload("res://scenes/atoms/argon_atom.tscn"),
	preload("res://scenes/atoms/potassium_atom.tscn"),
	preload("res://scenes/atoms/calcium_atom.tscn"),
	preload("res://scenes/atoms/scandium_atom.tscn"),
	preload("res://scenes/atoms/titanium_atom.tscn"),
	preload("res://scenes/atoms/vanadium_atom.tscn"),
	
	]
	
var special_atoms = [
	preload("res://scenes/special atoms/plus.tscn"),
	preload("res://scenes/special atoms/minus.tscn"),
	preload("res://scenes/special atoms/neutrino.tscn"),
	preload("res://scenes/special atoms/gluon.tscn")
]
#atom spawning variables
var weighted_pool = []
var smallest_value = 1
var minimum_weight = 1
var maximum_weight = 3

#game variables
var score = 0
var rounds_passed = 0
var plusless_rounds = 0
var level = 0

var grid_slot = preload("res://scenes/grid_slot.tscn")

var held_atom = []
var held_atom_instance = []
var lowest_atom_value = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_pool()
	maximum_weight = 3
	minimum_weight = 1
	
	for i in 5:
		held_atom.append(random_atom())
		held_atom_instance.append(held_atom[i].instantiate())
		add_child(held_atom_instance[i])
		held_atom_instance[i].position = Vector2(288+ (i*offset),900)
		if i == 0:
			held_atom_instance[i].scale = Vector2(atom_scale, atom_scale)
		else:
			held_atom_instance[i].scale = Vector2(next_atom_scale, next_atom_scale)
	
	print("HELD ATOMS")
	print(held_atom_instance)
	atomArray = make_2d_array()
	spawn_grid_slots()
	fill_array()

func spawn_grid_slots():
	for i in width:
		for j in height:
			var slot = grid_slot.instantiate()
			slot.position = grid_to_pixel(i,j)
			add_child(slot)
			
func make_2d_array():
	var array = []
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array
	
signal addScore(value)
func add_score(value):
	addScore.emit(value)
	
signal atomMerged()
func merge_at(column, row):
	print("merge called")
	#create four arrays that store the neighbors of the merge spot in order
	#first member of the array "left" is the first neighbor to the left, second member is second to left, etc 
	var storedValue = null
	var left = []
	var right = []
	var up = []
	var down = []
	var center = atomArray[column][row]
	var merge_time = center.total_merge_time
	for i in range(0,2):
		left.append(get_atom(column-(i+1),row))
		right.append(get_atom(column+(i+1),row))
		up.append(get_atom(column, row+(i+1)))
		down.append(get_atom(column, row-(i+1)))
	
	print(left)
	#check if left and right neighboring atoms exist and aren't empty spaces
	for i in range(0, 2):
		#if the left and right neighbors aren't empty, and are the same value, merge.
		if (left[i] != null && right[i] != null) && (left[i].value == right[i].value):
				#storedValue is the value that the plus atom will end up being by the end of the merging process
				if storedValue == null:
					storedValue = left[i].value
				else:
					if left[i].value >= atomArray[column][row].value:
						storedValue = left[i].value + 1
					else:
						storedValue += 1
				#animate the left and right atoms sliding inwards, then delete left, right, and center atom
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
				add_score(storedValue+1)
				atomMerged.emit()
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
				add_score(storedValue+1)
				atomMerged.emit()
		else:
			break
	#if the merging process goes through, (storedValue will not be null) then check for merges again.
	#this should lead to chain reactions.
	if storedValue != null:
		grid_logic()

	
func random_atom():
	var atom = weighted_pool.pick_random()
	return atom

func level_up():
	level += 1
	print("Level up! Level:")
	print(level)
	update_pool()

func update_pool():
	#clear pool
	weighted_pool = []
	#give pluses a weight of 5
	for i in 10:
		weighted_pool.append(special_atoms[0])
	#give minuses a weight of 1
	for i in 1:
		weighted_pool.append(special_atoms[1])
	#move the possible atom bracket up one, each atom bracket should have maximum_weight atoms total.
	#atom bracket STARTS at minimum_weight. minimum weight = 1 by default to start with hydrogen.
	#EX: maximum_weight = 5 -> starting weighted pool = [H, He, Li, Be, B]
	#maximum_weight = 5 -> after 2 level ups, weighted pool = [Li, Be, B, C, N]
	for i in maximum_weight:
		for j in 5:
			weighted_pool.append(possible_atoms[minimum_weight+i+level])
	for i in weighted_pool.size():
		print(weighted_pool[i].instantiate().value)

func fill_array():
	for i in width:
		for j in height:
			#choose a random number and store it
			var rand = floor(randf_range(0,starting_atoms.size()))
			#Instance piece from array
			if randi_range(1, 5) == 1:
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
func spawn_atom(x,y, type, appear = true):
	var atom
	x = posmod(x, width)
	y = posmod(y, height)
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
	if appear: atom.appear()

#DIFFERENT FROM slide_atom(), this is a helper function that takes an atom and moves it to a new position (animated). 
#this OVERWRITES the old atom.
func move_atom(x1,y1, x2,y2):
	#Modulo all of the input coordinates
	x1 = posmod(x1, width)
	y1 = posmod(y1, height)
	x2 = posmod(x2, width)
	y2 = posmod(y2, height)
	#get atom at the first set of coordinates (x1, y1)
	var atom = get_atom(x1,y1)
	#as long as the atom exists (isn't null), execute the atom's move function to the second set of coordinates (x2, y2)
	#NOTE: atom.move() is a purely visual function that handles animating the movement.
	#wait for the atom's total_merge_time, then erase the old atom and replace it with the new one.
	if atom != null:
		atom.move(x2,y2)
		await get_tree().create_timer(atom.total_merge_time).timeout
		atomArray[x1][y1] = null
		atomArray[x2][y2] = atom
		

#Debug function that allows the admin user to push any atom they want to the front of the queue
func atom_select():
	if Input.is_action_just_pressed("select_plus"):
		level_up()
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
		cycle_held_atom(special_atoms[3])
	if Input.is_action_just_pressed("store_atom"):
		cycle_held_atom(random_atom(), 4)
#Debug function that allows the admin user to delete any atom they want off of the board.
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
		x = posmod(x,width)
		y = posmod(y,height)
		if atomArray[x][y] != null:
			atomArray[x][y].queue_free()
			atomArray[x][y] = null
	else:
		if x != null:
			x.queue_free()
			x = null

#Special function for the gluon powerup
func slide_atom(x, y, direction: Vector2):
	var moveNum = null
	# if the slot next to the atom is open, just move the atom.
	
	if get_atom(x + (direction.x), y + (direction.y)) == null:
		move_atom(x, y, x+direction.x, y+direction.y)
	#otherwise, check in the direction of the swipe for the next empty space.
	else:
		
		for i in width:
			if get_atom(x + (direction.x * i), y + (direction.y * i)) == null:
				moveNum = i
				break
		
		#if the row / column is full, slide the entire row / column.
		#newAtomRow is the new position the atom row should be in, first move all atoms in desired direction (cosmetically)
		#then seamlessly update the grid by deleting the entire row and respawning atoms where they should be
		if moveNum == null:
			var newAtomRow = []
			for i in width:
				var atom = get_atom(x+((i-abs(direction.x))*direction.x),y+((i-abs(direction.y))*direction.y))
				newAtomRow.append(atom)
				atom.move(direction)
				
			await get_tree().create_timer(possible_atoms[1].instantiate().total_merge_time).timeout

			for i in width:
				var atom = get_atom(x+(i*direction.x),y+(i*direction.y))
				delete_atom(x+(i*direction.x),y+(i*direction.y))
				spawn_atom(x+(i*direction.x),y+(i*direction.y),newAtomRow[i], false)
		else:
			print(moveNum)
			for j in moveNum:
				var movementOffset = moveNum-j
				move_atom(x+(direction.x*(movementOffset-1)), y+(direction.y*(movementOffset-1)), x+(direction.x*(movementOffset)), y+(direction.y*(movementOffset)))
			

#automatically posmods all inputs, can accept grid coordinates above 5
#better to use this than directly reference atomArray
func get_atom(x,y):
	x = posmod(x,width)
	y = posmod(y,height)
	return atomArray[x][y]

func cycle_held_atom(atom, position = 0):
	
	#clear the held atom instance array.
	
		
	if position == 4:
		held_atom.pop_front()
		#checks if atom argunment is a packed scene or an int. If its an int, pull from the universal atom pool.
		if atom.has_method("instantiate"):
			held_atom.push_back(atom)
		else:
			held_atom.push_back(possible_atoms[atom.value])
	
	if position == 0:
		held_atom.pop_front()
		
		if atom.has_method("instantiate"):
			held_atom.push_front(atom)
		else:
			held_atom.push_front(possible_atoms[atom.value])
	
	for i in 5:
		if held_atom_instance[i].has_method("queue_free"):
			held_atom_instance[i].queue_free()
	held_atom_instance.clear()
	
	for i in 5:
		var new_atom = held_atom[i].instantiate()
		held_atom_instance.append(new_atom)
		new_atom.position = Vector2(288+(i*offset),900)
		if i == 0:
			new_atom.scale = Vector2(atom_scale, atom_scale)
		else:
			new_atom.scale = Vector2(next_atom_scale, next_atom_scale)
		add_child(held_atom_instance[i])
		#insert passed atom into held_atom array at passed position

#swiping variables
var x1
var y1
var x2
var y2
var grid_position1

signal passTurn()
func pass_turn():
	passTurn.emit()
	
var swipeDirection
var swipeStart
var swipeEnd
func receive_swipe(swipeStart, swipeEnd, swipeDirection):
	if held_atom_instance[0].ability == "move":
		print("direction:",swipeDirection)
		print("start coords:", swipeStart)
		print("end coords:", swipeEnd)
		var x = pixel_to_grid(swipeStart.x, swipeStart.y).x
		var y = pixel_to_grid(swipeStart.x, swipeStart.y).y
		if(get_atom(x,y) != null && is_instance_valid(get_atom(x,y))):
			slide_atom(x,y,swipeDirection)
			await get_tree().create_timer(atomArray[x][y].total_merge_time).timeout
			cycle_held_atom(random_atom(), 4)
			grid_logic()
			pass_turn()
	
func touch_input():
	#if the held atom's ability is move, allows the user to push / slide an atom.
	#the touch_input() function is aborted and control is given to the receive_swipe() function
	#which is connected to the autoload input handler system for swipe detection
		if held_atom_instance[0].ability == "move":
			return
		if Input.is_action_just_released("ui_touch"):
			var grid_position = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			if grid_position.x >= 0 && grid_position.x < width && grid_position.y >= 0 && grid_position.y < width:
				var x = grid_position.x
				var y = grid_position.y
				
				if held_atom_instance[0].ability == "minus":
					if atomArray[x][y] != null:
						atomArray[x][y].move(288 ,900, false, 2)
						await get_tree().create_timer(atomArray[x][y].total_merge_time).timeout
						cycle_held_atom(atomArray[x][y], 0)
						delete_atom(atomArray[x][y])
						pass_turn()
						
				if held_atom_instance[0].ability == "multiply":
					if atomArray[x][y] != null:
						cycle_held_atom(atomArray[x][y], 0)
						
				if atomArray[x][y] == null && (held_atom_instance[0].ability == "" or held_atom_instance[0].ability == "plus"):
					#delete last held atom instance
					
					spawn_atom(x,y, held_atom[0])
					#update held atom with random atom (random atom returns an atom instance of 
					#pass round and level up every 20 rounds
					rounds_passed += 1
					if(rounds_passed % 20 == 0):
						level_up()
					cycle_held_atom(random_atom(), 4)
					grid_logic()
					pass_turn()
#triggers on signal from a PowerUp instance, accepts string input for powerup type.
func usePowerUp(type):
	if(type == "move"):
		cycle_held_atom(special_atoms[3])

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
