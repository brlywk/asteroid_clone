extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%BackButton.pressed.connect($AnimationPlayer.play.bind("Hide"))


func show() -> void:
	$AnimationPlayer.play("Show")
