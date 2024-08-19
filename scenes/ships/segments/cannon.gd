class_name Cannon extends Segment

signal on_set_type(type: Bullet.Bullet_Type)
signal shot

const bullet_prefab: PackedScene = preload("res://scenes/projectiles/bullet.tscn")

@export var radius: int = 10

@onready var canon_rotation_point: Node2D = %RotationPoint


var type: Bullet.Bullet_Type:
	set(value):
		type = value
		on_set_type.emit(type)

func initialize(level_: Level, grid_position_: Vector2i) -> void:
	super.initialize(level_, grid_position_)
	type = randi_range(1, Bullet.Bullet_Type.size() - 1) as Bullet.Bullet_Type
	
func _trigger() -> void:
	var segments: Array = get_entity_in_radius(radius, is_active_enemy)
	
	if segments.is_empty():
		return
	
	var target: Segment = pick_target(segments)
	shoot(target)


func shoot(target: Segment) -> void:
	if is_destroyed:
		return
		
	var tween = get_tree().create_tween()

	tween.tween_property(canon_rotation_point, "rotation", target.global_position.angle_to_point(global_position), 0.1)
	await tween.finished
	
	if target == null:
		return

	var bullet: Bullet = bullet_prefab.instantiate()
	bullet.global_position = global_position
	bullet.rotation = canon_rotation_point.rotation
	bullet.direction = global_position.direction_to(target.global_position)
	bullet.ship = ship

	get_tree().get_root().add_child(bullet)
	
	shot.emit()
	
	bullet.type = type

func pick_target(possible_segments: Array) -> Segment:
	
	var highest_priority := 0
	var highest_priority_segments = []
	
	for segment in possible_segments:
		var seg_priority: int = get_segment_priority(segment)
		if  seg_priority > highest_priority:
			highest_priority_segments.clear()
			highest_priority = seg_priority
			highest_priority_segments.push_back(segment)
		elif seg_priority == highest_priority:
			highest_priority_segments.push_back(segment)
			
	return highest_priority_segments.pick_random()

func get_segment_priority(segment: Segment) -> int:
	if segment.broken:
		return 0
		
	if segment.is_head:
		return 2
	
	return 1
	
