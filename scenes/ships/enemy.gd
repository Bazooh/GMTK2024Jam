class_name Enemy extends Ship

@onready var minimap_stamp: Sprite2D = $Head/MinimapStamp

func _ready() -> void:
	super._ready()
	minimap_stamp.reparent(self.get_parent())
	died.connect(remove_stamp)
	segment_attached.connect(_on_segment_attached)
	segment_detached.connect(_on_segment_detached)
	
	avoid_big_desirability *= randf_range(1 - random_offset , 1 + random_offset)
	go_toward_center_desirability *= randf_range(1 - random_offset , 1 + random_offset)
	go_toward_segment_desirability *= randf_range(1 - random_offset , 1 + random_offset)
	go_toward_center_desirability *= randf_range(1 - random_offset , 1 + random_offset)
	move_randomly_desirability *= randf_range(1 - random_offset , 1 + random_offset)


@export var avoid_big_desirability: float = 0.5
@export var go_toward_small_desirability: float = 2.0
@export var go_toward_segment_desirability: float = 10.0
@export var go_toward_center_desirability: float = 0.1
@export var poison_avoidance_desirability: float = 0.05
@export var move_randomly_desirability: float = 0.01

@export var random_offset: float = 0.2


var cannon_count := 0


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

var desirability := Vector2.ZERO

func get_direction() -> Vector2i:
	
	desirability /= 2
	
	var current_chunk_id: Vector2i = level.get_chunk_id(head.grid_position)
	var size: int = segments.size()

	var center_vector = -head.global_position / level.tile_size
	desirability += go_toward_center_desirability * center_vector.normalized() / (pow(center_vector.length_squared() , 1.5) + 1)
	
	var radar_radius = level.get_radar_radius()

	if not level.is_inside_poison(head.grid_position):
		for x in range(-radar_radius, radar_radius + 1):
			for y in range(-radar_radius, radar_radius + 1):
				if (level.is_inside_poison(head.grid_position + Vector2i(level.chunk_size * Vector2(x,y)))):
					if abs(x) == 1:
						desirability.x += sin(x) * -abs(x) * poison_avoidance_desirability
					if abs(y) == 1:
						desirability.y += sin(y) * -abs(y) * poison_avoidance_desirability
					
					continue
					
				var chunk_id: Vector2i = current_chunk_id + Vector2i(x, y)
				

				if not level.chunks.has(chunk_id):
					continue
				
				for ship: Ship in level.chunks[chunk_id].ship:
					if ship == self:
						continue
					
					var desirability_sign: int = -1 if (ship.segments.size() > size or cannon_count == 0) else 1
					var vector: Vector2 = (ship.head.global_position - head.global_position) / level.tile_size
					desirability += desirability_sign * vector * avoid_big_desirability / pow(vector.length_squared(), 1.5)

				for segment: Segment in level.chunks[chunk_id].segment:
					if segment == null or segment.ship != null: continue
					var vector: Vector2 = segment.global_position - head.global_position
					desirability += vector * go_toward_segment_desirability / pow(vector.length_squared() / 8, 1.5)
					
	
	desirability += level.DIRECTIONS.pick_random() * move_randomly_desirability
	
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
	
	push_error("Invalid angle: " + str(desirability))
	return Vector2i.ZERO


func _move() -> void:
	var direction: Vector2i = get_direction()
	move(direction)
	
	update_stamp()

func _on_segment_attached(segment: Segment):
	if segment is Cannon:
		cannon_count += 1

func _on_segment_detached(segment: Segment):
	if segment is Cannon:
		cannon_count -= 1
