class_name Bullet extends Area2D

enum Bullet_Type {NONE, BLUE, RED, YELLOW}

var direction := Vector2.ZERO
var ship: Ship

var disabled := false

@export var speed: float = 200
@export var damage: int = 1

@export_group("Colour textures")
@export var blue_texture: Texture
@export var red_texture: Texture
@export var yellow_texture: Texture

var type : Bullet_Type:
	set(value):
		type = value
		match type:
			Bullet_Type.BLUE:
				sprite.texture = blue_texture
			Bullet_Type.RED:
				sprite.texture = red_texture
			Bullet_Type.YELLOW:
				sprite.texture = yellow_texture

@onready var sprite: Sprite2D = $Sprite

	

func _process(delta: float) -> void:
	if disabled:
		return
		
	global_position += direction * speed * delta


func _on_area_entered(area: Area2D) -> void:
	
	if disabled:
		return
		
	if area is Barrier and area.ship != ship and area.type == type:
		disabled = true
		hide()
		area.block_bullet()
		queue_free()
		return
		
	if area is Segment and area.ship != ship and not area.is_destroyed and area.ship != null:
		area.take_damage(damage)
		disabled = true
		hide()
		queue_free()
	
