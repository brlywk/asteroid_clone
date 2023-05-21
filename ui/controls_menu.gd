extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%BackButton.pressed.connect($AnimationPlayer.play.bind("Hide"))


func show_menu() -> void:
	$AnimationPlayer.play("Show")
