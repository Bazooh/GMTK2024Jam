class_name Enemy extends Ship


func _move() -> void:
	move(level.DIRECTIONS.pick_random())