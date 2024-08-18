class_name Cannon extends Segment

signal on_set_type(type: Bullet.Bullet_Type)

const bullet_prefab: PackedScene = preload("res://scenes/projectiles/bullet.tscn")

@export var radius: int = 10

@onready var canon_rotation_point: Node2D = %RotationPoint


var type : Bullet.Bullet_Type:
	set(value):
		type = value
		on_set_type.emit(type)

func initialize(level_: Level, grid_position_: Vector2i) -> void:
	super.initialize(level_, grid_position_)
	type = randi_range(1, Bullet.Bullet_Type.size() - 1)
	
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
	
	bullet.type = type
