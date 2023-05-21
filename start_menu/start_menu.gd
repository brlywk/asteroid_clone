extends Node2D
## Initially loaded scene when game starts. Also has a super fancy intro ;-)


@export var main_game_scene: PackedScene


# For learning purposes, using something different everywhere
# find_child() is slow with lots of nodes (better use Unique Name, or get_node())
@onready var SplashScreenLayer: CanvasLayer = find_child("SplashScreenLayer")
@onready var MusicPlayer: AudioStreamPlayer = $MusicPlayer
@onready var SplashLogo: Sprite2D = find_child("BarelyAwakeGames")
@onready var SplashScreenBackground: ColorRect = find_child("SplashScreenBackground")
@onready var QuitButton: Button = find_child("QuitButton")
@onready var SettingsButton: Button = find_child("SettingsButton")
@onready var HighscoresButton: Button = find_child("HighscoresButton")
@onready var StartButton: Button = find_child("StartButton")
@onready var ControlsButton: Button = find_child("ControlsButton")
@onready var SettingsMenu: ColorRect = find_child("SettingsMenu")
@onready var HighscoresMenu: ColorRect = find_child("HighscoresMenu")
@onready var ControlsMenu: ColorRect = find_child("ControlsMenu")
@onready var MainMenu: Control = find_child("MainMenuControl")
@onready var InfoLabel: Label = find_child("InfoLabel")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# splash screen
	var logo_size: Vector2 = SplashLogo.texture.get_size()
	var viewport_size: Vector2 = get_viewport_rect().size
	SplashLogo.position = viewport_size / 2
	var side_space: float = viewport_size.x / 4
	var scaled_logo_size_x: float = viewport_size.x - side_space
	var scaling_ratio: float = scaled_logo_size_x / logo_size.x
	SplashLogo.scale *= scaling_ratio
	
	# initial setup stuff
	InfoLabel.text = ""
	
	# signal connections
	QuitButton.pressed.connect(get_tree().quit)
	SettingsButton.pressed.connect(SettingsMenu.show_settings)
	HighscoresButton.pressed.connect(HighscoresMenu.show_highscores_menu)
	StartButton.pressed.connect(_on_start_button_pressed)
	ControlsButton.pressed.connect(ControlsMenu.show)
	
	
	# fade in logo
	_fade_in_splash_screen()
	Util.fade_music(MusicPlayer, true, 0.0, Settings.game_settings.music_volume, 3.0)


func _on_start_button_pressed() -> void:
	Util.fade_music(MusicPlayer, false, Settings.game_settings.music_volume, 0.0, 1.0)
	Util.fade_screen_element(MainMenu, false, 1.0, _start_main_scene)
	

func _start_main_scene() -> void:
	get_tree().change_scene_to_packed(main_game_scene)


func _set_info_label_text(new_text: String) -> void:
	InfoLabel.text = new_text


#---------- Splash screen animation ----------#

# for pracice's sake, let's do this with tweens
# NO SKIPPING MUHARHARHARHARHAR
func _fade_in_splash_screen() -> void:
	Util.fade_screen_element(SplashLogo, true, 3.0, _fade_out_splash_screen)


func _fade_out_splash_screen() -> void:
	Util.fade_screen_element(SplashLogo, false, 2.0, _fade_in_menu)

	
func _fade_in_menu() -> void:
	SplashScreenLayer.visible = false
	Util.fade_screen_element(MainMenu, true, 0.5, Callable(), false)
	
	
#---------- SIGNAL HANDLERS ----------#

func _on_start_button_mouse_entered() -> void:
	_set_info_label_text("Start a new game")


func _on_start_button_mouse_exited() -> void:
	_set_info_label_text("")


func _on_settings_button_mouse_entered() -> void:
	_set_info_label_text("Change the game settings")


func _on_settings_button_mouse_exited() -> void:
	_set_info_label_text("")


func _on_highscores_button_mouse_entered() -> void:
	_set_info_label_text("Show highscores")


func _on_highscores_button_mouse_exited() -> void:
	_set_info_label_text("")


func _on_quit_button_mouse_entered() -> void:
	_set_info_label_text("Quit to desktop")


func _on_quit_button_mouse_exited() -> void:
	_set_info_label_text("")


func _on_controls_button_mouse_entered() -> void:
	_set_info_label_text("Show game controls")


func _on_controls_button_mouse_exited() -> void:
	_set_info_label_text("")


func _on_music_player_finished() -> void:
	Util.fade_music(MusicPlayer, true, 0.0, Settings.game_settings.music_volume, 0.01)

