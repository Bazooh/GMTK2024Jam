class_name SpriteFlash extends Sprite2D

@export var flash_time = 0.1
@export var flash_intensity := 0.5
@export var damage_colour := Color.RED
@export var heal_colour := Color.GREEN

var flash_timer: Timer

func damage_flash():
	flash(damage_colour)

func heal_flash():
	flash(heal_colour)

func white_flash():
	flash(Color.WHITE)

func flash(colour : Color):
	if material is ShaderMaterial:
		material.set_shader_parameter("flash_color", colour)
		material.set_shader_parameter("flash_value", flash_intensity)
		
		if flash_timer == null:
			flash_timer = Timer.new()
			flash_timer.autostart = true
			add_child(flash_timer)
			flash_timer.timeout.connect(stop_flashing)
		flash_timer.start(flash_time)

		
			

func stop_flashing():
	material.set_shader_parameter("flash_value", 0)
