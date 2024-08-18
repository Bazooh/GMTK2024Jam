class_name Barrier extends Area2D

signal on_set_type(type: Bullet.Bullet_Type)
signal on_block

var ship : Ship

var type : Bullet.Bullet_Type:
	set(value):
		type = value
		on_set_type.emit(type)

func set_enabled(enabled: bool):
	visible = enabled
	monitoring = enabled
	monitorable = enabled

func block_bullet():
	on_block.emit()
