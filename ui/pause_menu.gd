extends ColorRect
## Pause menu


signal unpaused


var settings_menu: ColorRect
var highscores_menu: ColorRect


@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton
@onready var settings_button: Button = %SettingsButton
@onready var scores_button: Button = %HighscoresButton


@warning_ignore(return_value_discarded)
func _ready() -> void:
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(get_tree().quit)
	settings_button.pressed.connect(show_settings)
	scores_button.pressed.connect(show_highscores)


func unpause() -> void:
	animator.play("Hide")
	unpaused.emit()
	

func show() -> void:
	animator.play("Show")
	

func show_settings() -> void:
	settings_menu.show_settings()


func show_highscores() -> void:
	highscores_menu.show_highscores_menu()
