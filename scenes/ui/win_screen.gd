class_name WinScreen extends TextureRect

@onready var time_label: Label = $TimeLabel

func open(time: int):
	show()
	
	var seconds = time%60
	var minutes = time/60
	
	time_label.text = "Time: " + str(minutes) + ":" + str(seconds)
	
