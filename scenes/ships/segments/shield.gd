class_name Shield extends Segment

@onready var barrier: Barrier = $Barrier

signal on_set_type(type: Bullet.Bullet_Type)

var type : Bullet.Bullet_Type:
	set(value):
		type = value
		on_set_type.emit(type)

func initialize(level_: Level, grid_position_: Vector2i) -> void:
	super.initialize(level_, grid_position_)
	type =  randi_range(1, Bullet.Bullet_Type.size())
	barrier.type = type
	
	broke.connect(update_barrier)
	repaired.connect(update_barrier)
	activated.connect(update_barrier)
	deactivated.connect(update_barrier)
	
	update_barrier()
	

func update_barrier():
	barrier.set_enabled(ship != null and not broken)
	barrier.ship = ship
