class_name Player extends Ship


@export var movement_time: float = 0.1

@onready var camera: Camera2D = $Camera2D

var is_moving := false

func _ready() -> void:
	super._ready()

	var head: Segment = segments[0]
	camera.reparent(head)
	head.sprite.frame = 1


func _process(_delta: float) -> void:
	if Input.is_action_pressed("up"):
		move(Vector2i.UP)
	elif Input.is_action_pressed("down"):
		move(Vector2i.DOWN)
	elif Input.is_action_pressed("left"):
		move(Vector2i.LEFT)
	elif Input.is_action_pressed("right"):
		move(Vector2i.RIGHT)


func move(direction: Vector2i) -> void:
	if is_moving:
		return
	
	is_moving = true
	if can_move(direction):
		for segment in segments:
			segment.move(direction, movement_time)
	attach_adjacent_segments()
	level.turn_changed()

	await get_tree().create_timer(movement_time).timeout

	is_moving = false


func can_move(direction:Vector2i) -> bool:
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
