class_name Segment
extends Entity

var grid_position := Vector2.ZERO
var busy := false
var level : Level
var active := false


@onready var sprite: Sprite2D = $Sprite
@export var active_sprite: Texture2D

func initialize(level: Level):
	self.level = level
	grid_position = global_position / level.tile_size
	level.set_entity(grid_position, self)

func set_grid_position(new_position: Vector2):
	level.remove_entity(grid_position, self)
	grid_position = new_position
	level.set_entity(grid_position, self)

func can_move(direction: Vector2):
	return !busy and level.walkable(grid_position + direction)
	

func move(direction: Vector2, tween_time: float):
	set_grid_position(grid_position + direction)
	
	busy = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", grid_position * level.tile_size, tween_time)
	tween.tween_callback(finished_moving)

func finished_moving():
	busy = false

func activate():
	active = true
	if active_sprite != null:
		sprite.texture = active_sprite
	walkable = true
