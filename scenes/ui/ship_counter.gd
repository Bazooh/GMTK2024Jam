extends Label

@export var label_text := "Enemies remaining:"
@onready var flash_animation: AnimationPlayer = $FlashAnimation

func update_ship_label(num_ships):
	text = label_text + " " + str(num_ships)
	if flash_animation != null:
		flash_animation.play("Flash")
