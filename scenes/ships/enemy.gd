class_name Enemy extends Ship

@onready var minimap_stamp: Sprite2D = $Head/MinimapStamp

func _ready() -> void:
	super._ready()
	minimap_stamp.reparent(self.get_parent())
	died.connect(remove_stamp)
	

func _move() -> void:
	move(level.DIRECTIONS.pick_random())
	
	if level.player != null and level.player.head != null:
		var player_pos : Vector2 = level.player.head.global_position
		var dist_to_player : float = head.global_position.distance_to(player_pos)
		var dir_to_player : Vector2 = player_pos.direction_to(head.global_position)
		
		var stamp_pos = player_pos + (dir_to_player * dist_to_player)
		var minimap_size := level.player.minimap_size
		stamp_pos.x = clamp(stamp_pos.x, player_pos.x - minimap_size, player_pos.x + minimap_size)
		stamp_pos.y = clamp(stamp_pos.y, player_pos.y - minimap_size, player_pos.y + minimap_size)
		minimap_stamp.global_position = stamp_pos

func remove_stamp():
	minimap_stamp.queue_free()
