class_name Heal extends Segment

signal on_heal

@export var radius: int = 2
@export var heal_amount: int = 3
@export var reload_time: float = 3

@onready var reload_timer: Timer = $ReloadTimer

var loaded:= true

func _ready():
	super._ready()
	reload_timer.timeout.connect(reload)
	
func _trigger() -> void:
	var segments: Array = get_entity_in_radius(radius, is_ally)

	if segments.is_empty() or !loaded:
		return
		
	var target: Segment = Useful.sort(segments, func(seg: Segment) -> int: return seg.life)[0]
	if target.life < target.max_life:
		target.heal(heal_amount)
		on_heal.emit()
		loaded = false
		reload_timer.start(reload_time)
	else:
		loaded = false
		reload_timer.start(0.1)
		

func reload() -> void:
	loaded = true
