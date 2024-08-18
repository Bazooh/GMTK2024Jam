class_name Barrier extends Area2D

signal on_set_type(type: Bullet.Bullet_Type)

var ship : Ship
var sprite_show_time := 0.5

@onready var sprite_2d: SpriteFlash = $Sprite2D
@onready var show_timer: Timer = $ShowTimer

func _ready():
	show_timer.timeout.connect(hide_shield)
	hide_shield()
	
var type : Bullet.Bullet_Type:
	set(value):
		type = value
		on_set_type.emit(type)
		

func set_enabled(enabled: bool):
	visible = enabled
	monitoring = enabled
	monitorable = enabled

func block_bullet():
	sprite_2d.show()
	sprite_2d.white_flash()
	show_timer.start(sprite_show_time)

func hide_shield():
	sprite_2d.hide()
