class_name Ship extends Node2D


signal died


var level: Level
var segments: Array[Segment] = []

var head: Segment

@export var segment_frame = 0


func _ready() -> void:
	died.connect(_on_death)

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


func _on_death() -> void:
	for segment in segments:
		segment.deactivate()

	level.ships.erase(self)

	queue_free()


func trigger() -> void:
	for segment in segments:
		if is_instance_valid(segment):
			segment.trigger()


func end_turn() -> void:
	for segment in segments:
		if is_instance_valid(segment):
			segment.end_turn()
	
	#ship life depends on head for now
	if head.broken:
		died.emit()
		
	#if segments.all(func(seg: Segment) -> bool: return (not is_instance_valid(seg)) or seg.broken):
		#died.emit()


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
		activate_segment.reparent(self)
		activate_segment.ship = self
		segments.append(activate_segment)
	
	if not to_activate.is_empty():
		attach_adjacent_segments()
