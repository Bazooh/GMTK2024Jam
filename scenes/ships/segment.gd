class_name Segment
extends Entity

signal deactivated
signal activated
signal broke
signal repaired
signal destroyed
signal triggered
signal life_changed(current: int, max: int)
signal damaged
signal healed

var grid_position := Vector2i.ZERO
var level: Level

var is_destroyed

var broken := false
var is_head := false

#used for detaching
var marked := false

var active: bool:
	get:
		return ship != null and not is_destroyed

var ship: Ship:
	set(value):
		ship = value
		if value == null:
			$Sprite.frame_coords.x = 0
		else:
			$Sprite.frame_coords.x = value.segment_frame
		

@onready var sprite: SpriteFlash = $Sprite

@export var damage_percentage: float = 0.75
@export var broken_percentage: float = 0.5
@export var repair_percentage: float = 0.5


@export var max_life: int = 10
@onready var life: int = max_life:
	set(value):
		life = clamp(value, 0, max_life)
		life_changed.emit(value, max_life)
		
		if life > float(max_life)*damage_percentage:
			sprite.frame_coords.y = 0
		elif life > float(max_life)*broken_percentage:
			sprite.frame_coords.y = 1
		else:
			sprite.frame_coords.y = 2


func _ready() -> void:
	super._ready()

	if is_in_group("Head"):
		is_head = true


func initialize(level_: Level, grid_position_: Vector2i) -> void:
	if level != null:
		return

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
	if is_destroyed:
		return
		
	set_grid_position(grid_position + direction)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", grid_position * level.tile_size, movement_time)


func end_turn():
	if is_destroyed:
		return
	
	if grid_position.x < -level.poison_distance or grid_position.x >= level.poison_distance or grid_position.y < -level.poison_distance or grid_position.y >= level.poison_distance:
		take_damage(1)
		
	if life <= 0:
		destroy()
		
	elif not broken and life <= float(max_life) * broken_percentage:
		broke.emit()
	
	elif broken and life > int(repair_percentage * max_life):
		repaired.emit()


func _trigger() -> void:
	pass


func trigger() -> void:
	if active and not is_destroyed:
		triggered.emit()
		_trigger()


func take_damage(amount: int):
	life -= amount
	sprite.damage_flash()
	damaged.emit()


func heal(amount: int):
	life += amount
	sprite.heal_flash()
	healed.emit()


func _on_broke():
	sprite.modulate = Color.GRAY
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


func activate(ship_: Ship) -> void:
	ship = ship_
	reparent(ship_)
	level.chunks[level.get_chunk_id(grid_position)].segment.erase(self)
	activated.emit()


func deactivate() -> void:
	ship = null
	reparent(level.inactive_segments)
	level.chunks[level.get_chunk_id(grid_position)].segment.add(self)
	deactivated.emit()


func destroy() -> void:
	level.remove_entity(grid_position, self)
	
	level.chunks[level.get_chunk_id(grid_position)].segment.erase(self)
	if ship == null:
		pass
	else:
		ship.remove_segment(self)
	
	destroyed.emit()
	hide()
	is_destroyed = true
	monitoring = false
	monitorable = false
	queue_free()
