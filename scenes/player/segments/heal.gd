class_name Heal extends Segment


@export var radius: int = 10


func _trigger() -> void:
	var segments: Array = get_entity_in_radius(radius, is_ally)
	
	if segments.is_empty():
		return

	var target: Segment = Useful.sort(segments, func(seg: Segment) -> int: return seg.life)[0]
	target.life += 1
