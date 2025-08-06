extends Button
@onready var cooldownLabel = $Cooldown

@export var powerUp: String
@export var maxCooldown: int
@export var cooldown: int = 0

func _ready():
	self.pressed.connect(_button_pressed)
	show()
	update_text()
	
func update_text():
	cooldownLabel.text = str(cooldown)

func turn_passed():
	if(cooldown > 0):
		cooldown -= 1
		update_text()
		
	if(cooldown == 0):
		disabled = false
	else:
		disabled = true

signal usePowerUp(power)
func _button_pressed():
	print(powerUp)
	cooldown = maxCooldown
	update_text()
	usePowerUp.emit(powerUp)
	
	if(cooldown == 0):
		disabled = false
	else:
		disabled = true
