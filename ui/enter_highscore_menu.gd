extends ColorRect


signal score_saved


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	
	# Just trying out different ways to do things, for the sake of learning ;)
	%OkButton.pressed.connect(save_score)
	%CancelButton.pressed.connect(hide)
	
	# focus edit box
	%NameEditBox.grab_focus()


func save_score() -> void:
	var player_name: String = %NameEditBox.text
	
	if player_name:
		Scores.add_highscore(player_name, GameStats.score, GameStats.level)
	
	self.visible = false
	score_saved.emit()


func show_menu() -> void:
	%HeaderLabel.text = "Score: " + str(GameStats.score) + " / Level: " + str(GameStats.level)
	self.visible = true
	
	
func hide_menu() -> void:
	score_saved.emit()
	self.visible = false
