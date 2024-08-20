class_name WinScreen extends TextureRect

@onready var time_label: Label = $TimeLabel
@onready var win_sound: AudioStreamPlayer = $WinSound

func open(time: int):
	show()
	
	var seconds: int = time % 60
	var minutes := int(time / 60.0)
	
	time_label.text = "Time: " + str(minutes) + ":" + str(seconds)
	
	win_sound.play()
	
