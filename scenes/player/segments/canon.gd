class_name Canon extends Segment


@export var radius: int = 10


func _trigger() -> void:
	var segments: Array = get_entity_in_radius(radius, is_active_enemy)
	
	if segments.is_empty():
		return
	
	var target: Segment = segments.pick_random()
	target.life -= 1

	print("Canon shot at : ", target.grid_position, ", health left : ", target.life)
