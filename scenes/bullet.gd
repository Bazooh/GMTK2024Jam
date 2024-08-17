class_name Bullet extends Sprite2D


@export var speed: float = 200

var target: Segment

func _process(delta: float) -> void:
	if target == null or target.global_position.distance_squared_to(global_position) < 10:
		queue_free()
		return
	
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta

	rotation = direction.angle()
