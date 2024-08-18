class_name Ship extends Node2D


signal died

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

	head = segments[0]
	head.is_head = true
	head.destroyed.connect(death)


func death() -> void:
	for segment in segments:
		segment.deactivate()

	if head != null:
		head.is_head = false
	level.ships.erase(self)

	died.emit()
	queue_free()


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
	if can_move(direction):
		for segment in segments:
			segment.move(direction, level.movement_time)
	attach_adjacent_segments()


func can_move(direction: Vector2i) -> bool:
	for segment in segments:
		if not segment.can_move(direction):
			return false
	return true


func attach_adjacent_segments() -> void:
	var to_activate := Set.new()

	for segment in segments:
		to_activate.add_all(level.get_adjacent_unowned_segments(segment.grid_position))
	
	for activate_segment in to_activate:
		activate_segment.activate(self)
		segments.append(activate_segment)
	
	if not to_activate.is_empty():
		attach_adjacent_segments()

func remove_segment(segment: Segment) -> void:
	segments.erase(segment)
	remove_detached_segments()

func remove_detached_segments() -> void:
	#mark all segments still attached to head
	if not head.is_destroyed:
		mark_segments(head)
	
	#detach all unmarked segments
	var attached_segments : Array[Segment] = []
	
	for segment in segments:
		if segment.marked:
			segment.marked = false
			attached_segments.append(segment)
		else:
			segment.deactivate()
	
	segments = attached_segments
	
func mark_segments(segment: Segment):
	if segment.marked:
		return
	
	segment.marked = true
	
	for direction in level.DIRECTIONS:
		var adjacent = level.get_entity(segment.grid_position + direction)
		if segment.is_ally(adjacent):
			mark_segments(adjacent)
