extends Button
@onready var cooldownLabel = $Cooldown

@export var powerUp: String
@export var maxCooldown: int
@export var cooldown: int = 0
@export var charges: int = 0
@export var rechargeType: String

func _ready():
	self.pressed.connect(_button_pressed)
	show()
	update_text()
	if(rechargeType == "merge" && charges <= 0):
			disabled = true
	
func update_text():
	if(rechargeType == "turn"):
		cooldownLabel.text = str(cooldown)
	if(rechargeType == "merge"):
		cooldownLabel.text = str(charges)

func turn_passed():
	if(rechargeType == "turn"):
		if(cooldown > 0):
			cooldown -= 1
			update_text()
			
		if(cooldown == 0):
			disabled = false
		else:
			disabled = true

func atom_merged():
	if(rechargeType == "merge"):
		charges += 1
		update_text()
		
		if(charges <= 0):
			disabled = true
		else:
			disabled = false

signal usePowerUp(power)
func _button_pressed():
	print(powerUp, " charges: ", charges)
	cooldown = maxCooldown
	charges -= 1
	update_text()
	usePowerUp.emit(powerUp)
	
	if(rechargeType == "turn"):
		if(cooldown == 0):
			disabled = false
		else:
			disabled = true
	
	if(rechargeType == "merge"):
		if(charges <= 0):
			disabled = true
	
