class_name Ship extends Node2D


signal died
signal size_changed
signal segment_attached(segment: Segment)
signal segment_detached(segment: Segment)

var level: Level
var segments: Array[Segment] = []

var head: Segment

@export var segment_frame = 0


func _ready() -> void:

	level = (get_tree().get_first_node_in_group("level") as Level)

	assert(level != null, "No level node found")

	level.ships.append(self)

	for child in get_children():
		if child is Segment:
			segments.append(child)
			child.initialize(level, child.global_position / level.tile_size)
			child.ship = self
	
	assert(not segments.is_empty(), "No segments in ship")
	
	size_changed.emit()

	head = segments[0]
	head.is_head = true
	head.destroyed.connect(death)


func death() -> void:
	for segment in segments:
		segment.deactivate()

	if head != null:
		head.is_head = false
	level.remove_ship(self)

	died.emit()
	# queue_free()


func trigger() -> void:
	for segment in segments:
		if is_instance_valid(segment):
			segment.trigger()


func end_turn() -> void:
	for segment in segments:
		if is_instance_valid(segment):
			segment.end_turn()
	
	#ship dies when head is destroyed for now
	#if segments.all(func(seg: Segment) -> bool: return (not is_instance_valid(seg)) or seg.broken):
		#death()


func _move() -> void:
	pass


func move(direction: Vector2i) -> void:
	var head_chunk = level.get_chunk_id(head.grid_position)

	if head.grid_position.x >= 160 or head.grid_position.y >= 160:
		breakpoint

	if can_move(direction):
		for segment in segments:
			segment.move(direction, level.movement_time)
	
	var new_head_chunk = level.get_chunk_id(head.grid_position)
	if new_head_chunk != head_chunk:
		level.chunks[head_chunk].ship.erase(self)
		level.chunks[new_head_chunk].ship.add(self)

	attach_adjacent_segments()


func can_move(direction: Vector2i) -> bool:
	return segments.all(func(segment: Segment) -> bool: return segment.can_move(direction))


func attach_adjacent_segments() -> void:
	var to_activate := Set.new()

	for segment in segments:
		to_activate.add_all(level.get_adjacent_unowned_segments(segment.grid_position))
	
	for activate_segment in to_activate:
		add_segment(activate_segment)
	
	if not to_activate.is_empty():
		attach_adjacent_segments()


func add_segment(segment: Segment) -> void:
	segment.activate(self)
	segments.append(segment)
	segment_attached.emit(segment)

	size_changed.emit()


func remove_segment(segment: Segment) -> void:
	segments.erase(segment)
	segment_detached.emit(segment)
	remove_detached_segments()

	size_changed.emit()


func remove_detached_segments() -> void:
	#mark all segments still attached to head
	if head.is_destroyed:
		return
		
	mark_segments(head)
	
	#detach all unmarked segments
	var attached_segments : Array[Segment] = []
	
	for segment in segments:
		if segment.marked:
			segment.marked = false
			attached_segments.append(segment)
		else:
			segment.deactivate()
			segment_detached.emit(segment)
	
	segments = attached_segments

	size_changed.emit()


func mark_segments(segment: Segment):
	if segment.marked:
		return
	
	segment.marked = true
	
	for direction in level.DIRECTIONS:
		var adjacent = level.get_entity(segment.grid_position + direction)
		if segment.is_ally(adjacent):
			mark_segments(adjacent)
