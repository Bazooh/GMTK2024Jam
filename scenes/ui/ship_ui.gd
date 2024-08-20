class_name ShipUI extends Control

var enabled:= true

@onready var health_bar: TextureProgressBar = $HealthBar

func _ready():
	var level = (get_tree().get_first_node_in_group("level") as Level)
	if level and level.menu:
		disable_health_bar()
	
func set_health_bar(current_health: int, max_health: int):
	if not enabled:
		return
		
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	if current_health == 0:
		health_bar.hide()
	else:
		health_bar.show()


func disable_health_bar() -> void:
	enabled = false
	health_bar.hide()
