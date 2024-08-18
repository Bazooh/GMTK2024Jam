class_name Heal extends Segment

signal on_heal

@export var radius: int = 2
@export var heal_amount: int = 5
@export var reload_time: float = 2.5

@onready var reload_timer: Timer = $ReloadTimer

var loaded := true

func _ready():
	super._ready()
	reload_timer.timeout.connect(reload)
	
func _trigger() -> void:
	var segments: Array = get_entity_in_radius(radius, is_ally)

	if segments.is_empty() or !loaded:
		return
		
	loaded = false

	var target: Segment = Useful.sort(segments, func(seg: Segment) -> float: return float(seg.life) / seg.max_life)[0]
	if target.life < target.max_life:
		target.heal(heal_amount)
		on_heal.emit()
		reload_timer.start(reload_time)
	else:
		reload_timer.start(0.1)
		

func reload() -> void:
	loaded = true
