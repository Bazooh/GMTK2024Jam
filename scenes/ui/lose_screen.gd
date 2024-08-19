class_name LoseScreen extends TextureRect

@onready var rank_label: Label = $RankLabel

func open(rank: int):
	show()
	
	rank_label.text = "You ranked #" + str(rank)
	
