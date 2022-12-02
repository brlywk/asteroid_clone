extends ColorRect
## Pause menu


signal unpaused


var settings_menu: ColorRect


@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton
@onready var settings_button: Button = %SettingsButton


@warning_ignore(return_value_discarded)
func _ready() -> void:
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(get_tree().quit)
	settings_button.pressed.connect(show_settings)


func unpause() -> void:
	animator.play("Unpause")
	unpaused.emit()
	

func show() -> void:
	animator.play("Pause")
	

func show_settings() -> void:
	settings_menu.show_settings()
