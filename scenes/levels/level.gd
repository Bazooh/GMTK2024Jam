class_name Level
extends Node2D


const DIRECTIONS := [Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN]

const segments_prefab: Array[PackedScene] = [
	preload("res://scenes/ships/segments/cannon.tscn"),
	preload("res://scenes/ships/segments/heal.tscn"),
	preload("res://scenes/ships/segments/shield.tscn")
]

const enemy_prebab: PackedScene = preload("res://scenes/ships/enemy.tscn")

const tile_size: float = 16.0
const chunk_size: int = 16

@onready var inactive_segments: Node2D = %InactiveSegments

@export var movement_time: float = 0.1
@export var segment_density: float = 0.01

var grid := {}
var ships: Array[Ship] = []
var chunk_generated := Set.new()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _ready() -> void:
	for inactive_segment in inactive_segments.get_children():
		inactive_segment.initialize(self, inactive_segment.global_position / tile_size)


func walkable(ship: Ship, pos: Vector2i) -> bool:
	var entity: Entity = get_entity(pos)
	
	return entity == null or (entity is Segment and entity.ship == ship)


func set_entity(pos: Vector2i, entity: Entity, set_pos := true) -> void:
	if set_pos:
		entity.global_position = pos * tile_size
	grid[pos] = entity


func remove_entity(pos: Vector2i, entity: Entity = null) -> void:
	assert(grid.has(pos), "Trying to remove entity that doesn't exist")

	if entity != null and grid[pos] != entity:
		return
	
	grid.erase(pos)


func get_entity(pos: Vector2i) -> Entity:
	if grid.has(pos):
		return grid[pos]
	return null


func get_adjacent_unowned_segments(pos: Vector2i) -> Array:
	var search := []

	for direction: Vector2i in DIRECTIONS:
		var new_pos: Vector2i = pos + direction
		if has_unowned_segment(new_pos):
			search.append(grid[new_pos])

	return search


func has_unowned_segment(pos: Vector2i) -> bool:
	var entity: Entity = get_entity(pos)
	return entity != null and entity is Segment and entity.ship == null


func turn_changed() -> void:
	for ship in ships:
		ship._move()
	
	for ship in ships:
		ship.trigger()
	
	for ship in ships:
		ship.end_turn()


func _on_each_tick() -> void:
	turn_changed()


func generate_ship(pos: Vector2i) -> void:
	var ship: Ship = enemy_prebab.instantiate()
	ship.global_position = pos * tile_size
	add_child.call_deferred(ship)


func add_random_segment(pos: Vector2i) -> void:
	if randf() < 0.2:
		generate_ship(pos)
		return

	var new_segment: Segment = segments_prefab.pick_random().instantiate()
	inactive_segments.add_child(new_segment)
	new_segment.initialize(self, pos)


func generater_chunk(chunk_id: Vector2i) -> void:
	if chunk_generated.has(chunk_id):
		return

	for x in range(chunk_id.x * chunk_size, (chunk_id.x + 1) * chunk_size):
		for y in range(chunk_id.y * chunk_size, (chunk_id.y + 1) * chunk_size):
			var pos := Vector2i(x, y)
			if not grid.has(pos) and randf() < segment_density:
				add_random_segment(pos)
	
	chunk_generated.add(chunk_id)


func get_chunk_id(pos: Vector2i) -> Vector2i:
	return pos / chunk_size


func generate_chunks_around(pos: Vector2i, radius: int) -> void:
	var chunk_id: Vector2i = get_chunk_id(pos)
	
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			generater_chunk(chunk_id + Vector2i(x, y))
