class_name Player extends Ship


@onready var camera: Camera2D = $Camera2D
var is_moving := false

@export var chunk_radius: int = 2

@export var minimap_stamp: Sprite2D


func _ready() -> void:
	super._ready()

	if not level.is_node_ready():
		await level.ready

	camera.reparent(head)
	head.sprite.frame = 1

	level.generate_chunks_around(head.grid_position, chunk_radius)

	#size_changed.connect(_on_size_changed)
	#size_changed.emit()


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

	var tween: Tween = create_tween()
	tween.tween_property(minimap_stamp, "rotation", Vector2(direction).angle() + PI / 4, 0.1)

	level.generate_chunks_around(head.grid_position, chunk_radius)

	await get_tree().create_timer(level.movement_time).timeout

	is_moving = false


func _on_size_changed() -> void:
	var bounds: Rect2i = Useful.get_boundsi(segments.map(func(seg: Segment): return seg.grid_position))
	var size: int = max(bounds.size.x, bounds.size.y)

	var zoom: Vector2 = 3 * exp(-0.08 * size) * Vector2.ONE

	var tween: Tween = create_tween()
	tween.tween_property(camera, "zoom", zoom, 2.0)
