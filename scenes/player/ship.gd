class_name Ship extends Node2D


signal died


var level: Level
var segments: Array[Segment] = []


func _ready() -> void:
	died.connect(_on_death)

	level = (get_tree().get_first_node_in_group("level") as Level)

	assert(level != null, "No level node found")

	level.ships.append(self)
	
	for child in get_children():
		if child is Segment:
			segments.append(child)
			child.initialize(level)
			child.ship = self
	
	assert(not segments.is_empty(), "No segments in ship")


func _on_death() -> void:
	for segment in segments:
		# level.remove_entity(segment.grid_position)
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
	
	if segments.all(func(seg: Segment) -> bool: return (not is_instance_valid(seg)) or seg.broken):
		died.emit()	