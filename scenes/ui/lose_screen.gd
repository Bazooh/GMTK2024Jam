class_name LoseScreen extends TextureRect

@onready var rank_label: Label = $RankLabel
@onready var lose_sound: AudioStreamPlayer = $LoseSound

func open(rank: int):
	show()
	
	rank_label.text = "You ranked " + str(rank)
	lose_sound.play()
