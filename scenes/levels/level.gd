class_name Level
extends Node2D

signal ships_updated(num_ships)

const DIRECTIONS := [Vector2i.UP, Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN]

const segments_prefab: Array[PackedScene] = [
	preload("res://scenes/ships/segments/cannon.tscn"),
	preload("res://scenes/ships/segments/heal.tscn"),
	preload("res://scenes/ships/segments/shield.tscn")
]

const enemy_prebab: PackedScene = preload("res://scenes/ships/enemy.tscn")

const poison_prefab: PackedScene = preload("res://scenes/levels/poison.tscn")
const wall_prefab: PackedScene = preload("res://scenes/levels/wall.tscn")

const bullet_prefab: PackedScene = preload("res://scenes/projectiles/bullet.tscn")

const tile_size: float = 16.0
const chunk_size: int = 16

@onready var inactive_segments: Node2D = %InactiveSegments
@onready var ships_node: Node2D = $Ships
@onready var clouds: Clouds = $"../Clouds"
var win_screen: WinScreen
var lose_screen: LoseScreen
var pause_screen: Pause
@onready var bullet_pool: Node2D = %BulletPool


@export var movement_time: float = 0.1
@export var segment_density: float = 0.002
@export var enemy_density: float = 0.002
@export var enemy_starting_segments : int = 1
@export var enemy_extra_segment_chance: float = 0.5
@export var menu := false

@export var map_size: int = 10
@export var n_ships: int = 99
@export var infinite_map := false

var grid := {}
var chunks := {}
var ships: Array[Ship] = []
var chunk_generated := Set.new()
var inactive_bullets := Set.new()

var game_over : bool
var time = 0

var player: Player

@onready var poison_distance: int = map_size * chunk_size + 1

func get_radar_radius() -> int:
	if n_ships > 90:
		return 1
	elif n_ships > 60:
		return 2
	elif n_ships > 20:
		return 3
	else:
		return 4



func restart():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _ready() -> void:
	pass
	get_tree().root.get_viewport().set_canvas_cull_mask_bit.call_deferred(1, false)

	#for inactive_segment in inactive_segments.get_children():
		#inactive_segment.initialize(self, inactive_segment.global_position / tile_size)
	
	if not infinite_map:
		generate_map()
	
	time = 0
	
	if not menu:
		win_screen = %WinScreen
		lose_screen = %LoseScreen
		pause_screen = %PauseScreen


func _process(delta):
	time += delta


func add_bullet() -> void:
	var bullet: Bullet = bullet_prefab.instantiate()
	bullet.initialize(self)
	bullet_pool.add_child.call_deferred(bullet)


func init_bullet_pool() -> void:
	for i in range(500):
		add_bullet()


func fire_bullet(ship: Ship, pos: Vector2, direction: Vector2, type: Bullet.Bullet_Type) -> void:
	if inactive_bullets.is_empty():
		add_bullet()
	
	var bullet: Bullet = inactive_bullets.pop_front()
	bullet.activate(ship, pos, direction, type)


func place_walls() -> void:
	
	if game_over or menu:
		return
		
	for i in range(-poison_distance, poison_distance):
		var poses: Array[Vector2i] = [
			Vector2i(i, -poison_distance),
			Vector2i(i, poison_distance - 1),
			Vector2i(-poison_distance, i),
			Vector2i(poison_distance - 1, i)
		]

		for pos: Vector2i in poses:
			var wall: Node2D = wall_prefab.instantiate()
			wall.global_position = pos * tile_size
			add_child.call_deferred(wall)


func walkable(ship: Ship, pos: Vector2i) -> bool:
	var size: int = map_size * chunk_size
	if pos.x < -size or pos.x >= size or pos.y < -size or pos.y >= size:
		return false

	var entity: Entity = get_entity(pos)
	return entity == null or (entity is Segment and entity.ship == ship)


func set_entity(pos: Vector2i, entity: Entity, set_pos := true) -> void:
	if set_pos:
		entity.global_position = pos * tile_size
	grid[pos] = entity


func remove_entity(pos: Vector2i, entity: Entity = null) -> void:
	if !grid.has(pos):
		push_error("Trying to remove entity that doesn't exist!")
		return

	if entity != null and grid[pos] != entity:
		return
	
	grid.erase(pos)


func get_entity(pos: Vector2i) -> Entity:
	if not grid.has(pos):
		return null
	
	if grid[pos] == null:
		grid.erase(pos)
		return null
	
	return grid[pos]


func get_adjacent_unowned_segments(pos: Vector2i) -> Array:
	var search := []

	for direction: Vector2i in DIRECTIONS:
		var new_pos: Vector2i = pos + direction
		if has_unowned_segment(new_pos):
			search.append(grid[new_pos])

	return search

func get_adjacent_free_spots(pos: Vector2i) -> Array:
	var search := []

	for direction: Vector2i in DIRECTIONS:
		var new_pos: Vector2i = pos + direction
		if walkable(null, new_pos):
			search.append(new_pos)

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


func generate_ship(pos: Vector2i) -> Ship:
	var ship: Ship = enemy_prebab.instantiate()

	chunks[get_chunk_id(pos)].ship.add(ship)
	
	ship.get_node("Head").initialize(self, pos)
	ships_node.add_child.call_deferred(ship)
	
	if not menu:
		return
		
		
	var free_spots = get_adjacent_free_spots(pos)
	var generated_segments = 0
	
	if enemy_extra_segment_chance >= 0.9:
		enemy_extra_segment_chance = 0.9
	
	while (len(free_spots) > 0 and (generated_segments < enemy_starting_segments or randf() < enemy_extra_segment_chance)):
		var segment_pos : Vector2i = free_spots.pick_random()
		
		var new_segment: Segment = segments_prefab.pick_random().instantiate()
		new_segment.global_position = segment_pos * tile_size
		ship.add_child.call_deferred(new_segment)
		new_segment.initialize(self, segment_pos)
		
		generated_segments += 1
		free_spots.erase(segment_pos)
		free_spots += get_adjacent_free_spots(segment_pos)
	

	return ship
	
	

func generate_segment(pos: Vector2i) -> Segment:
	var new_segment: Segment = segments_prefab.pick_random().instantiate()
	inactive_segments.add_child(new_segment)
	new_segment.initialize(self, pos)
	return new_segment


func generater_chunk(chunk_id: Vector2i) -> void:
	if chunks.has(chunk_id):
		return
	
	chunks[chunk_id] = {"ship": Set.new(), "segment": Set.new()}

	for x in range(chunk_id.x * chunk_size, (chunk_id.x + 1) * chunk_size):
		for y in range(chunk_id.y * chunk_size, (chunk_id.y + 1) * chunk_size):
			var pos := Vector2i(x, y)

			if not grid.has(pos): 
				if randf() < segment_density:
					chunks[chunk_id].segment.add(generate_segment(pos))
	
	clouds.generate_clouds(chunk_id * chunk_size * tile_size, chunk_size * tile_size)


func get_chunk_id(pos: Vector2i) -> Vector2i:
	return pos / chunk_size


func generate_chunks_around(pos: Vector2i, radius: int) -> void:
	if not infinite_map:
		return

	var chunk_id: Vector2i = get_chunk_id(pos)
	
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			generater_chunk(chunk_id + Vector2i(x, y))


func get_random_free_pos() -> Vector2i:
	var size: int = map_size * chunk_size

	var pos := Vector2i(randi_range(-size, size - 1), randi_range(-size, size - 1))
	while get_entity(pos) != null:
		pos = Vector2i(randi_range(-size, size - 1), randi_range(-size, size - 1))
	return pos


func generate_map() -> void:
	for x in range(-map_size, map_size):
		for y in range(-map_size, map_size):
			generater_chunk(Vector2i(x, y))
	
	for i in range(n_ships):
		generate_ship(get_random_free_pos())
	
	place_walls()
	
	ships_updated.emit(n_ships)


func remove_ship(ship: Ship) -> void:
	ships.erase(ship)
	chunks[get_chunk_id(ship.head.grid_position)].ship.erase(ship)

	if menu:
		return
		
	if ship is Player and not game_over:
		lose_game()
		return
	
	n_ships -= 1
	ships_updated.emit(n_ships)

	if not game_over and n_ships == 0:
		win_game()


func win_game() -> void:
	game_over = true
	win_screen.open(time)
	pause_screen.disabled = true


func lose_game() -> void:
	game_over = true
	lose_screen.open(n_ships + 1)
	pause_screen.disabled = true


func map_shrink() -> void:
	poison_distance -= 1

	for i in range(-poison_distance, poison_distance):
		var poses: Array[Vector2i] = [
			Vector2i(i, -poison_distance),
			Vector2i(i, poison_distance - 1),
			Vector2i(-poison_distance, i),
			Vector2i(poison_distance - 1, i)
		]

		for pos: Vector2i in poses:
			var poison: Node2D = poison_prefab.instantiate()
			poison.global_position = pos * tile_size
			add_child.call_deferred(poison)


func is_inside_poison(pos: Vector2i) -> bool:
	return pos.x < -poison_distance or pos.x >= poison_distance or pos.y < -poison_distance or pos.y >= poison_distance


func _on_random_scrap_timeout() -> void:
	var pos: Vector2i = get_random_free_pos()
	chunks[get_chunk_id(pos)].segment.add(generate_segment(pos))
