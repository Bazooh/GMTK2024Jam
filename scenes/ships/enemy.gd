class_name Enemy extends Ship

@onready var minimap_stamp: Sprite2D = $Head/MinimapStamp

func _ready() -> void:
	super._ready()
	minimap_stamp.reparent(self.get_parent())
	died.connect(remove_stamp)
	

## In chunks
@export var radar_radius: int = 3

@export var avoid_big_desirability: float = 0.5
@export var go_toward_small_desirability: float = 2.0
@export var go_toward_segment_desirability: float = 5.0
@export var go_toward_center_desirability: float = 0.2


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


func remove_stamp():
	minimap_stamp.queue_free()


func get_direction() -> Vector2i:
	var current_chunk_id: Vector2i = level.get_chunk_id(head.grid_position)
	var size: int = segments.size()

	var center_vector = -head.global_position / level.tile_size
	var desirability: Vector2 = go_toward_center_desirability * center_vector / pow(center_vector.length_squared(), 1.5)

	if not level.is_inside_poison(head.grid_position):
		for x in range(-radar_radius, radar_radius + 1):
			for y in range(-radar_radius, radar_radius + 1):
				var chunk_id: Vector2i = current_chunk_id + Vector2i(x, y)

				if not level.chunks.has(chunk_id):
					continue

				for ship: Ship in level.chunks[chunk_id].ship:
					if ship == self:
						continue
					
					var desirability_sign: int = -1 if ship.segments.size() > size else 1
					var vector: Vector2 = (ship.head.global_position - head.global_position) / level.tile_size
					desirability += desirability_sign * vector * avoid_big_desirability / pow(vector.length_squared(), 1.5)

				for segment: Segment in level.chunks[chunk_id].segment:
					if segment == null: continue
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
			return Vector2i.DOWN
		-2, 2:
			return Vector2i.LEFT
		-1:
			return Vector2i.UP
	
	push_error("Invalid angle: " + str(rounded_angle))
	return Vector2i.ZERO


func _move() -> void:
	var direction: Vector2i = get_direction()
	move(direction)
	
	update_stamp()
