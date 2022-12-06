extends ColorRect


@onready var ScoresGrid: GridContainer = %ScoresGrid
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var BackButton: Button = %BackButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BackButton.pressed.connect(hide_highscores_menu)
	
	_reset_scores()
	_add_scores()
	
	
func _reset_scores() -> void:
	for n in ScoresGrid.get_children():
		var str_name: String = String(n.name)
		
		if not str_name.contains("Header"):
			n.queue_free()
	
	
func _add_scores() -> void:
	var scores: Array[HighscoreEntry] = Scores.highscores.get_top_ten()

	for score in scores:
		var NameLabel: Label = Label.new()
		NameLabel.text = score.player_name
		ScoresGrid.add_child(NameLabel)
		
		var ScoreLabel: Label = Label.new()
		ScoreLabel.text = str(score.score)
		ScoresGrid.add_child(ScoreLabel)
		
		var LevelLabel: Label = Label.new()
		LevelLabel.text = str(score.level)
		LevelLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		ScoresGrid.add_child(LevelLabel)


func show_highscores_menu() -> void:
	animation_player.play("Show")
	
	
func hide_highscores_menu() -> void:
	animation_player.play("Hide")
