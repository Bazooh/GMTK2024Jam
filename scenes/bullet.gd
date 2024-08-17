class_name Bullet extends Area2D


@export var speed: float = 200

var direction := Vector2.ZERO
var ship: Ship


func _process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area is not Segment or area.ship == ship or area.broken:
		return

	area.life -= 1
	queue_free()
