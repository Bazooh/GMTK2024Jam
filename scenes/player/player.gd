class_name Player extends Ship


@onready var camera: Camera2D = $Camera2D
var is_moving := false

@export var chunk_radius: int = 2


func _ready() -> void:
	super._ready()

	await level.ready

	camera.reparent(head)
	head.sprite.frame = 1

	level.generate_chunks_around(head.grid_position, chunk_radius)


func _process(_delta: float) -> void:
	if Input.is_action_pressed("up"):
		move_and_wait(Vector2i.UP)
	elif Input.is_action_pressed("down"):
		move_and_wait(Vector2i.DOWN)
	elif Input.is_action_pressed("left"):
		move_and_wait(Vector2i.LEFT)
	elif Input.is_action_pressed("right"):
		move_and_wait(Vector2i.RIGHT)


func move_and_wait(direction: Vector2i) -> void:
	if is_moving:
		return
	
	is_moving = true
	move(direction)

	level.generate_chunks_around(head.grid_position, chunk_radius)

	await get_tree().create_timer(level.movement_time).timeout

	is_moving = false