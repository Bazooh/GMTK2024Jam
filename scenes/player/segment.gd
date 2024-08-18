class_name Segment
extends Entity


signal broke
signal repaired
signal life_changed(current: int, max: int)
signal deactivated


var grid_position := Vector2i.ZERO
var level: Level

var broken := false

var is_enemy_head := false

var active: bool:
	get:
		return ship != null and not broken

var ship: Ship:
	set(value):
		ship = value
		if value == null:
			sprite.frame = 0
		else:
			sprite.frame = value.segment_frame
		

@onready var sprite: Sprite2D = $Sprite

@export var repair_percentage: float = 0.5


@export var max_life: int = 10
@onready var life: int = max_life:
	set(value):
		life = clamp(value, 0, max_life)
		life_changed.emit(value, max_life)


func initialize(level_: Level, grid_position_: Vector2i) -> void:
	level = level_
	grid_position = grid_position_
	level.set_entity(grid_position, self)


func set_grid_position(new_position: Vector2i):
	level.remove_entity(grid_position, self)
	grid_position = new_position
	level.set_entity(grid_position, self, false)


func can_move(direction: Vector2i):
	return level.walkable(ship, grid_position + direction)
	

func move(direction: Vector2i, movement_time: float):
	set_grid_position(grid_position + direction)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", grid_position * level.tile_size, movement_time)


func end_turn():
	if life <= 0:
		broke.emit()
	
	elif life > int(repair_percentage * max_life):
		repaired.emit()


func _trigger() -> void:
	pass


func trigger() -> void:
	if active:
		_trigger()


func _on_broke():
	sprite.modulate.a = 0.5
	broken = true


func _on_repaired():
	sprite.modulate.a = 1
	broken = false


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
	deactivated.emit()
