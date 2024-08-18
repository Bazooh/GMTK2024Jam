extends SpriteFlash

@export_group("Colour textures")
@export var blue_texture: Texture
@export var red_texture: Texture
@export var yellow_texture: Texture

var type : Bullet.Bullet_Type:
	set(value):
		type = value
		match type:
			Bullet.Bullet_Type.BLUE:
				texture = blue_texture
			Bullet.Bullet_Type.RED:
				texture = red_texture
			Bullet.Bullet_Type.YELLOW:
				texture = yellow_texture
			_:
				push_warning("Not a valid type!")


func _set_type(type_: Bullet.Bullet_Type):
	type = type_
