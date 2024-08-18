extends Control

var enabled:= true

@onready var health_bar: TextureProgressBar = $HealthBar

func set_health_bar(current: int, max: int):
	if not enabled:
		return
		
	health_bar.max_value = max
	health_bar.value = current
	
	if current == 0:
		health_bar.hide()
	else:
		health_bar.show()


func disable_health_bar() -> void:
	enabled = false
	health_bar.hide()
