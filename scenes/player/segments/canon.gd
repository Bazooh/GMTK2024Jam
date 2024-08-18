class_name Canon extends Segment


const bullet_prefab: PackedScene = preload("res://scenes/bullet.tscn")

@export var radius: int = 10

@onready var canon_rotation_point: Node2D = %RotationPoint


func _trigger() -> void:
	var segments: Array = get_entity_in_radius(radius, is_active_enemy)
	
	if segments.is_empty():
		return
	
	var target: Segment = segments.pick_random()
	shoot(target)


func shoot(target: Segment) -> void:
	var tween = get_tree().create_tween()

	tween.tween_property(canon_rotation_point, "rotation", target.global_position.angle_to_point(global_position), 0.1)
	await tween.finished

	var bullet: Bullet = bullet_prefab.instantiate()
	bullet.global_position = global_position
	bullet.rotation = canon_rotation_point.rotation
	bullet.direction = global_position.direction_to(target.global_position)
	bullet.ship = ship

	get_tree().get_root().add_child(bullet)
