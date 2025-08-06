extends Node2D
signal swipe
var swipe_start = null
var minimum_drag = 100

func _unhandled_input(event):
	if event.is_action_pressed("ui_touch"):
		swipe_start = get_global_mouse_position()
	if event.is_action_released("ui_touch"):
		_calculate_swipe(get_global_mouse_position())
		
func _calculate_swipe(swipe_end):
	if swipe_start == null: 
		return
	var swipeVector = swipe_end - swipe_start
	var direction = null
	print(swipeVector)
	if abs(swipeVector.x) < minimum_drag:
		swipeVector.x = 0
	if abs(swipeVector.y) < minimum_drag:
		swipeVector.y = 0
	if swipeVector.y == 0 && swipeVector.x == 0:
		return
	if abs(swipeVector.x) > abs(swipeVector.y):
		if swipeVector.x > 0:
			direction = Vector2(1,0)
			print("right")
		else:
			direction = Vector2(-1,0)
			print("left")
	else:
		if swipeVector.y > 0:
			direction = Vector2(0,1)
			print("down")
		else:
			direction = Vector2(0,-1)
			print("up")
	swipe.emit(swipe_start, swipe_end, direction)
