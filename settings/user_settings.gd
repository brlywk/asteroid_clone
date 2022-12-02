extends Node
## Handles loading and saving of game settings, as well as actually
## applying those settings to the game
##
## Autoloaded as: Settings


var game_settings: GameSettings
var game_settings_path: String = ProjectSettings.globalize_path("user://config.tres")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ResourceLoader.exists(game_settings_path):
		game_settings = ResourceLoader.load(game_settings_path) as GameSettings
	else:
		game_settings = GameSettings.new()
		
	_init_audio()
	_init_video()


#---------- PUBLIC FUNCTIONS ----------#

@warning_ignore(return_value_discarded)
## Saves current settings to disk
func save_game_settings() -> void:
	ResourceSaver.save(game_settings, game_settings_path)


## Switches between fullscreen modes
func set_fullscreen(mode: int) -> void:
	game_settings.fullscreen = mode
	DisplayServer.window_set_mode(mode)
	save_game_settings()
	

## Sets games master (overall) volume
func set_master_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),
		Util.volume_percent_to_db(value))
	game_settings.master_volume = value
	save_game_settings()


## Sets music volume
func set_music_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),
		Util.volume_percent_to_db(value))
	game_settings.music_volume = value
	save_game_settings()
	

# Sets effects volume
func set_effects_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"),
		Util.volume_percent_to_db(value))
	game_settings.effects_volume = value
	save_game_settings()


## All-purpose function to set any game setting
##
## Used to avoid having multiple single line functions setting a single property
func set_property(prop_name: String, value: Variant) -> void:
	game_settings.set(prop_name, value)
	save_game_settings()
	

## Sets the asteroids line weight
##
## This cannot be done with the "all-purpose" set_property function,
## as Asteroid settings are dependent on asteroid size
func set_asteroid_line_weight(a_size: Util.AsteroidSize, value: float):
	var property_name: String
	
	match a_size:
		Util.AsteroidSize.SMALL:
			property_name = "asteroid_line_weight_small"
		Util.AsteroidSize.MEDIUM:
			property_name = "asteroid_line_weight_medium"
		Util.AsteroidSize.LARGE:
			property_name = "asteroid_line_weight_large"
	
	game_settings.set(property_name, value)
	
	save_game_settings()


#---------- PRIVATE FUNCTIONS ----------#
func _init_audio() -> void:
	set_master_volume(game_settings.master_volume)
	
	
func _init_video() -> void:
	DisplayServer.window_set_mode(game_settings.fullscreen)

