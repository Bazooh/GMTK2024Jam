class_name Clouds extends Node2D

@export var cloud_sprites : Array[Texture] = []
const cloud_scene = preload("res://scenes/levels/Clouds/cloud.tscn")

const min_jump := 0.0
const max_jump := 10.0

var clouds: Array[Sprite2D] = []

#spawn clouds within the bounds of the chunk
func generate_clouds(chunk_start: Vector2, chunk_size: float):
	var x: float = 0.0
	var y: float = 0.0
	
	while (x < chunk_size and y < chunk_size):
		var texture : Texture = cloud_sprites.pick_random()
		
		var cloud : Sprite2D = cloud_scene.instantiate()
		cloud.texture = texture
		cloud.global_position = Vector2(chunk_start.x + x, chunk_start.y + y)
		add_child(cloud)
		
		x += cloud.get_rect().size.x * 2
		y += cloud.get_rect().size.y * 2
		
		x += randf_range(min_jump, max_jump)
		y += randf_range(min_jump, max_jump)
