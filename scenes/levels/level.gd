class_name Level
extends Node2D


const tile_size: float = 16.0

@onready var ground: TileMapLayer = $Ground

@export var grid_size: int = 20
@onready var inactive_segments: Node2D = %InactiveSegments

var grid: Array = []
var ships: Array[Ship] = []


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _ready() -> void:
	for i in grid_size:
		grid.append([])
		for j in grid_size:
			var tile: Tile = Tile.new()
			grid[i].append(tile)
			tile.gridPos = Vector2i(i, j)
			tile.walkable = (ground.get_cell_tile_data(tile.gridPos) != null)
	
	for inactive_segment in inactive_segments.get_children():
		inactive_segment.initialize(self)


func walkable(ship: Ship, pos: Vector2i) -> bool:
	if not is_in_grid(pos):
		return false
	var tile: Tile = grid[pos.x][pos.y]

	if tile.is_walkable():
		return true
	
	return tile.entity != null and tile.entity is Segment and tile.entity.ship == ship


func set_entity(pos: Vector2i, entity: Entity) -> void:
	assert(is_in_grid(pos), "Trying to set entity outside of grid")

	grid[pos.x][pos.y].entity = entity


func remove_entity(pos: Vector2i, entity: Entity = null) -> void:
	assert(is_in_grid(pos), "Trying to remove entity outside of grid")

	if entity != null and grid[pos.x][pos.y].entity != entity:
		return
	
	grid[pos.x][pos.y].entity = null


func get_entity(pos: Vector2i) -> Entity:
	if is_in_grid(pos):
		return grid[pos.x][pos.y].entity
	return null


func is_in_grid(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < grid_size and pos.y < grid_size


func get_adjacent_unowned_segments(pos: Vector2i) -> Array:
	var search := []
	if (has_unowned_segment(pos + Vector2i.UP)):
		search.append(grid[pos.x][pos.y - 1].entity)
	if (has_unowned_segment(pos + Vector2i.RIGHT)):
		search.append(grid[pos.x + 1][pos.y].entity)
	if (has_unowned_segment(pos + Vector2i.LEFT)):
		search.append(grid[pos.x - 1][pos.y].entity)
	if (has_unowned_segment(pos + Vector2i.DOWN)):
		search.append(grid[pos.x][pos.y + 1].entity)
	return search


func has_unowned_segment(pos: Vector2i) -> bool:
	if not is_in_grid(pos):
		return false
	var tile: Tile = grid[pos.x][pos.y]
	return (tile.entity != null and tile.entity is Segment and tile.entity.ship == null)


func turn_changed() -> void:
	for ship in ships:
		ship.trigger()
	
	for ship in ships:
		ship.end_turn()


func _on_each_tick() -> void:
	turn_changed()
