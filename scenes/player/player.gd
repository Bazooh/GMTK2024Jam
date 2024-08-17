class_name Player
extends Node2D

var level : Level

var segments := []

@export var tween_time = 0.1

@onready var camera: Camera2D = $Camera2D

func _ready():
	level = (get_tree().get_first_node_in_group("level") as Level)
	if level == null:
		push_error("No level node found")
		
	for child in get_children():
		if child is Segment:
			segments.push_back(child)
			child.initialize(level)
			child.activate()
	
	if len(segments) > 0:
		camera.reparent(segments[0])
	else:
		push_error("No segments in player")

func _process(delta: float):
	if Input.is_action_pressed("up"):
		move(Vector2.UP)
	elif Input.is_action_pressed("down"):
		move(Vector2.DOWN)
	elif Input.is_action_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_pressed("right"):
		move(Vector2.RIGHT)
	
func move(direction: Vector2):
	if can_move(direction):
		for segment in segments:
			segment.move(direction, tween_time)
	attach_adjacent_segments()

func can_move(direction:Vector2) -> bool:
	for segment in segments:
		if not segment.can_move(direction):
			return false
	return true

func attach_adjacent_segments():
	var to_activate := []
	for segment in segments:
		to_activate += level.get_adjacent_inactive_segments(segment.grid_position)
	for activate_segment in to_activate:
		activate_segment.activate()
		activate_segment.reparent(self)
		segments.push_back(activate_segment)
