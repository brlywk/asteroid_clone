extends CanvasLayer
## Main script handling UI related updates in-game


@onready var health_node: GridContainer = %HealthGridContainer
@onready var score_node: Label = %ScoreLabel
@onready var center_label: Label = %CenterLabel
@onready var LevelLabel: Label = %LevelLabel


func _ready() -> void:
	GameStats.player_health_changed.connect(_on_player_health_change)
	GameStats.score_changed.connect(_on_score_change)
	GameStats.level_changed.connect(update_level_label)


func increase_health() -> void:
	health_node.current_health += 1
	
	
func decrease_health() -> void:
	health_node.current_health -= 1
	
	
func reset_ui(player_shape: PackedVector2Array) -> void:
	center_label.visible = false
	health_node.player_health_icon_shape = player_shape
	health_node.current_health = 3
	score_node.score = 0
	update_level_label(1)


func show_center_label(message: String) -> void:
	center_label.visible = true
	center_label.text = message


func hide_center_label() -> void:
	center_label.visible = false


func update_level_label(level: int) -> void:
	LevelLabel.text = "Level " + str(level)
	
	
func show_enter_highscore_prompt() -> void:
	%EnterHighscoreMenu.show()


# ---------- Signal Handlers ---------- #

func _on_player_health_change(old_value: int, new_value: int) -> void:
	if new_value > old_value:
		increase_health()
	elif old_value > new_value:
		decrease_health()
	else:
		pass # should not happen... seriously!

func _on_score_change(new_value: int) -> void:
	score_node.score = new_value
