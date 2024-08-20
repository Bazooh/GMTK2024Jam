extends Control

@onready var click_sound: AudioStreamPlayer = $ClickSound

var played := false

func play():
	if played:
		return
		
	played = true
	click_sound.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/levels/test_level.tscn")
