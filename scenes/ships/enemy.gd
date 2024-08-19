class_name Enemy extends Ship

@onready var minimap_stamp: Sprite2D = $Head/MinimapStamp


@export var radar_radius: int = 5

@export var avoid_big_desirability: float = 0.5
@export var go_toward_small_desirability: float = 2.0
@export var go_toward_segment_desirability: float = 5.0


func update_stamp() -> void:
	if level.player == null or level.player.head == null:
		return
	
	var player_pos: Vector2 = level.player.head.global_position
	var dist_to_player: float = head.global_position.distance_to(player_pos)
	var dir_to_player: Vector2 = player_pos.direction_to(head.global_position)

	var stamp_pos: Vector2 = player_pos + (dir_to_player * dist_to_player)
	var minimap_size: float = level.player.minimap_size
	stamp_pos.x = clamp(stamp_pos.x, player_pos.x - minimap_size, player_pos.x + minimap_size)
	stamp_pos.y = clamp(stamp_pos.y, player_pos.y - minimap_size, player_pos.y + minimap_size)
	minimap_stamp.global_position = stamp_pos


func get_direction() -> Vector2i:
	var unowned_segments := Set.new()
	var ships := Set.new()

	for x in range(-radar_radius, radar_radius + 1):
		for y in range(-radar_radius, radar_radius + 1):
			var pos : Vector2i = head.grid_position + Vector2i(x, y)
			
			var entity: Entity = level.get_entity(pos)
			if entity is not Segment:
				continue
			
			if entity.ship == null:
				unowned_segments.add(entity)
			elif entity.ship != self:
				ships.add(entity.ship)
	
	var desirability := Vector2.ZERO

	var size: int = segments.size()

	for ship: Ship in ships:
		var desirability_sign: int = -1 if ship.segments.size() > size else 1
		var vector: Vector2 = (ship.head.global_position - head.global_position) / level.tile_size
		desirability += desirability_sign * vector * avoid_big_desirability / pow(vector.length_squared(), 1.5)

	for segment: Segment in unowned_segments:
		var vector: Vector2 = segment.global_position - head.global_position
		desirability += vector * go_toward_segment_desirability / pow(vector.length_squared(), 1.5)
	
	if desirability.is_zero_approx():
		return level.DIRECTIONS.pick_random()

	var angle: float = desirability.angle()
	var rounded_angle: int = round(angle / PI * 2)

	match rounded_angle:
		0:
			return Vector2i.RIGHT
		1:
			return Vector2i.UP
		-2, 2:
			return Vector2i.LEFT
		-1:
			return Vector2i.DOWN
	
	push_error("Invalid angle: " + str(rounded_angle))
	return Vector2i.ZERO


func _move() -> void:
	var direction: Vector2i = get_direction()
	move(direction)
	
	update_stamp()