class_name Level
extends Node2D

const tile_size : int = 16

@onready var ground: TileMapLayer = $Ground

@export var grid_size := 20
@onready var inactive_segments: Node2D = $InactiveSegments

var grid : Array = []

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
		
func _ready():
	for i in grid_size:
		grid.push_back([])
		for j in grid_size:
			var tile : Tile = Tile.new()
			grid[i].push_back(tile)
			tile.gridPos = Vector2(i,j)
			tile.walkable = (ground.get_cell_tile_data(tile.gridPos) != null)
	
	for inactive_segment in inactive_segments.get_children():
		inactive_segment.initialize(self)


func walkable(pos: Vector2) -> bool:
	return in_grid(pos) and grid[pos.x][pos.y].is_walkable()

func set_entity(pos: Vector2, entity: Entity):
	if in_grid(pos):
		grid[pos.x][pos.y].entity = entity

func remove_entity(pos: Vector2, entity: Entity = null):
	if in_grid(pos):
		if entity != null and grid[pos.x][pos.y].entity != entity:
			return
		grid[pos.x][pos.y].entity = null
			
func in_grid(pos: Vector2) -> bool:
	var in_range := pos.x >= 0 and pos.y >= 0 and pos.x < grid_size and pos.y < grid_size
	if not in_range:
		push_warning("Trying to access tile out of grid")
	return in_range

func get_adjacent_inactive_segments(pos: Vector2) -> Array:
	var search := []
	if (has_inactive_segment(pos + Vector2.UP)):
		search.push_back(grid[pos.x][pos.y - 1].entity)
	if (has_inactive_segment(pos + Vector2.RIGHT)):
		search.push_back(grid[pos.x + 1][pos.y].entity)
	if (has_inactive_segment(pos + Vector2.LEFT)):
		search.push_back(grid[pos.x - 1][pos.y].entity)
	if (has_inactive_segment(pos + Vector2.DOWN)):
		search.push_back(grid[pos.x][pos.y + 1].entity)
	return search

func has_inactive_segment(pos: Vector2) -> bool:
	if not in_grid(pos):
		return false
	var tile = grid[pos.x][pos.y]
	return (tile.entity != null and tile.entity is Segment and not tile.entity.active)
