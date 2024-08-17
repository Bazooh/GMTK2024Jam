class_name Segment
extends Entity


signal broke


var grid_position := Vector2i.ZERO
var level: Level
var ship: Ship
var broken := false

var active: bool:
	get:
		return ship != null and not broken


@onready var sprite: Sprite2D = $Sprite
@export var active_sprite: Texture2D


@export var max_life: int = 10
@onready var life: int = max_life:
	set(value):
		life = clamp(value, 0, max_life)


func _ready() -> void:
	super._ready()

	broke.connect(_on_broke)


func initialize(level_: Level):
	self.level = level_
	grid_position = global_position / level.tile_size
	level.set_entity(grid_position, self)


func set_grid_position(new_position: Vector2i):
	level.remove_entity(grid_position, self)
	grid_position = new_position
	level.set_entity(grid_position, self)


func can_move(direction: Vector2i):
	return level.walkable(ship, grid_position + direction)
	

func move(direction: Vector2i, movement_time: float):
	set_grid_position(grid_position + direction)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", grid_position * level.tile_size, movement_time)


func end_turn():
	if life <= 0:
		broke.emit()


func _trigger() -> void:
	pass


func trigger() -> void:
	if active:
		_trigger()


func _on_broke():
	sprite.modulate.a = 0.5
	broken = true


func is_enemy(entity: Entity) -> bool:
	return entity is Segment and entity.ship != ship


func is_active_enemy(entity: Entity) -> bool:
	return is_enemy(entity) and entity.active


func is_ally(entity: Entity) -> bool:
	return entity is Segment and entity.ship == ship


func get_entity_in_radius(radius: int, filter: Callable = func(_entity: Entity) -> bool: return true) -> Array:
	var entities: Array = []
	
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var entity: Entity = level.get_entity(grid_position + Vector2i(x, y))
			if entity != null and filter.call(entity):
				entities.append(entity)
	
	return entities


func deactivate() -> void:
	ship = null
	reparent(level.inactive_segments)