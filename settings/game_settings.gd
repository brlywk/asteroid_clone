class_name GameSettings
extends Resource
## Settings used for the game
##
## Note: Not itself autoloaded, that's done in user_settings.gd


@export_group("Audio")
@export var master_volume: float = 100.0
@export var music_volume: float = 70.0
@export var effects_volume: float = 100.0

@export_group("Display")
@export var fullscreen: int = DisplayServer.WINDOW_MODE_WINDOWED

@export_group("UI")
@export var font_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var player_health_line_weight: float = 1.0

@export_group("Player")
@export var player_line_color: Color = Color(0.0, 0.0, 1.0, 1.0)
@export var player_line_weight: float = 2.0

@export_group("Weapons")
@export var bullet_line_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var bullet_line_weight: float = 1.0

@export_group("Asteroids")
@export var asteroid_line_color: Color = Color(0.0, 1.0, 0.0, 1.0)
@export var asteroid_line_weight_small: float = 1.5
@export var asteroid_line_weight_medium: float = 2.0
@export var asteroid_line_weight_large: float = 2.5


## Creates a dictionary containing all current settings
func create_dictionary() -> Dictionary:
	var current_settings: Dictionary = {}
	
	var this_script: GDScript = get_script()
	
	for prop in this_script.get_script_property_list():
		var prop_name = prop.name
		var prop_value = get(prop_name)
		
		# filter out @export_group properties
		if prop_value != null:
			current_settings[prop_name] = prop_value
		
	return current_settings
