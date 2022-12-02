extends Label


@export var score: int = 0:
	get:
		return score
	set(new_value):
		self.text = "Score: " + str(new_value)
		score = new_value


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
