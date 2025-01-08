extends Resource

@export var value: int
@export var color: Color
@export var ability: String

func _init(p_value = 1, p_color = Color.BLUE, p_ability = null):
	value = p_value
	color = p_color
	ability = p_ability

func setValue(p_value):
	value = p_value
