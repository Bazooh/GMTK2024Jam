class_name Pause extends TextureRect

var paused := false
@export var show := true
@onready var button_sound: AudioStreamPlayer = $ButtonSound
var disabled := false

func _input(_event: InputEvent):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause():
	if disabled or (not paused and get_tree().paused):
		return
	
	button_sound.play()
	paused = !paused
	get_tree().paused = paused
	visible = paused and show

func return_to_menu():
	button_sound.play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
func _on_resume_pressed() -> void:
	toggle_pause()

func _on_menu_pressed() -> void:
	return_to_menu()
