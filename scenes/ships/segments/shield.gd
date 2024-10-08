class_name Shield extends Segment

@onready var barrier: Barrier = $Barrier

signal on_set_type(type: Bullet.Bullet_Type)

@export var damage_change := 0.1

var type : Bullet.Bullet_Type:
	set(value):
		type = value
		on_set_type.emit(type)

func initialize(level_: Level, grid_position_: Vector2i) -> void:
	super.initialize(level_, grid_position_)
	
	broke.connect(update_barrier)
	repaired.connect(update_barrier)
	activated.connect(update_barrier)
	deactivated.connect(update_barrier)
	
	
func _ready():
	type =  randi_range(1, Bullet.Bullet_Type.size() - 1) as Bullet.Bullet_Type
	barrier.type = type
	update_barrier()

func update_barrier():
	barrier.set_enabled(ship != null and not broken)
	barrier.ship = ship


func _on_barrier_blocked() -> void:
	if randf() < damage_change:
		take_damage(1)
