extends ColorRect
## Handles all actions and signals related to the settings menu
## 
## Note: Some settings are immediately written back to the game settings


signal optics_changed(changes: Dictionary)


var _previous_settings: Dictionary
var _changed_settings: Dictionary = {}


# fullscreen
@onready var fullscreen_button: CheckButton = %FullscreenButton

# master volume
@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var master_volume_label: Label = %MasterVolumeLabel

# music
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var music_volume_label: Label = %MusicVolumeLabel

# effects
@onready var effects_volume_slider: HSlider = %EffectsVolumeSlider
@onready var effects_volume_label: Label = %EffectsVolumeLabel

# player
@onready var player_color_picker: ColorPickerButton = %PlayerColorPickerButton
@onready var player_line_size_slider: HSlider = %PlayerLineSizeSlider
@onready var player_line_size_label: Label = %PlayerLineSizeLabel

# attacks
@onready var bullet_color_picker: ColorPickerButton = %BulletColorPickerButton
@onready var bullet_line_size_slider: HSlider = %BulletLineSizeSlider
@onready var bullet_line_size_label: Label = %BulletLineSizeLabel

# asteroids
@onready var asteroid_color_picker: ColorPickerButton = %AsteroidColorPickerButton
@onready var small_asteroid_line_size_slider: HSlider = %SmallAsteroidLineSizeSlider
@onready var small_asteroid_line_size_label: Label = %SmallAsteroidLineSizeLabel
@onready var medium_asteroid_line_size_slider: HSlider = %MediumAsteroidLineSizeSlider
@onready var medium_asteroid_line_size_label: Label = %MediumAsteroidLineSizeLabel
@onready var large_asteroid_line_size_slider: HSlider = %LargeAsteroidLineSizeSlider
@onready var large_asteroid_line_size_label: Label = %LargeAsteroidLineSizeLabel

# others
@onready var tab_container: TabContainer = find_child("TabContainer")
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var InfoLabel: Label = find_child("InfoLabel")


func _ready() -> void:
	# get previous settings to know what should emit the settings changed signal
	_previous_settings = Settings.game_settings.create_dictionary()
	
	# info
	InfoLabel.text = ""
	
	# load saved / initial settings
	fullscreen_button.button_pressed = Settings.game_settings.fullscreen == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	master_volume_slider.value = Settings.game_settings.master_volume
	music_volume_slider.value = Settings.game_settings.music_volume
	effects_volume_slider.value = Settings.game_settings.effects_volume
	
	player_color_picker.color = Settings.game_settings.player_line_color
	player_line_size_slider.value = Settings.game_settings.player_line_weight
	
	bullet_color_picker.color = Settings.game_settings.bullet_line_color
	bullet_line_size_slider.value = Settings.game_settings.bullet_line_weight
	
	asteroid_color_picker.color = Settings.game_settings.asteroid_line_color
	small_asteroid_line_size_slider.value = Settings.game_settings.asteroid_line_weight_small
	medium_asteroid_line_size_slider.value = Settings.game_settings.asteroid_line_weight_medium
	large_asteroid_line_size_slider.value = Settings.game_settings.asteroid_line_weight_large
	
	# rename tabs using assigned "tab_name" metadata
	for i in tab_container.get_tab_count():
		tab_container.set_tab_title(i, tab_container.get_tab_control(i).get_meta("tab_name"))

	
func show_settings() -> void:
	animator.play("Show")


func _set_info_label_text(new_text: String) -> void:
	InfoLabel.text = new_text
	

## Quick check if a settings has actually changed
func _setting_has_changed(property_name: String, new_value: Variant) -> bool:
	# check if the property is actually in our settings (might have a typo when calling...)
	if _previous_settings.has(property_name):
		return _previous_settings[property_name] != new_value
		
	# default case should be true, because even if something goes wrong, we "save" an unchanging
	# value, which should have no negative impact
	return false
	

## As optics settings require a redaw, catch those, check if there actually
## are any changes, and apply the changed settings
func _check_and_apply_changed_settings() -> void:
	# needed to check if settings truly changed and we need to emit the signal
	var optics_have_changed: bool = false
	
	# check which settings changed
	for key in _changed_settings.keys():
		# lazyness
		var value: Variant = _changed_settings[key]
		
		if _setting_has_changed(key, value):
			optics_have_changed = true
			
			# is this is an asteroid line size setting, we need to handle it differently
			match key:
				"asteroid_line_weight_small":
					Settings.set_asteroid_line_weight(Util.AsteroidSize.SMALL, value)
				"asteroid_line_weight_medium":
					Settings.set_asteroid_line_weight(Util.AsteroidSize.MEDIUM, value)
				"asteroid_line_weight_large":
					Settings.set_asteroid_line_weight(Util.AsteroidSize.LARGE, value)
				"fullscreen":
					if value:
						Settings.set_fullscreen(DisplayServer.WINDOW_MODE_FULLSCREEN)
					else:
						Settings.set_fullscreen(DisplayServer.WINDOW_MODE_WINDOWED)
				_: # default case
					Settings.set_property(key, value)
					
		# delete unchanged settings
		else:
			_changed_settings.erase(key)
			
	# emit change signal
	if optics_have_changed:
		optics_changed.emit(_changed_settings)


#---------- SIGNAL HANDLERS ----------#

## Back button -> Hide menu and apply changed settings
func _on_back_button_pressed() -> void:
	_check_and_apply_changed_settings()
	animator.play("Hide")


# Fullscreen
func _on_fullscreen_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		_changed_settings["fullscreen"] = DisplayServer.WINDOW_MODE_FULLSCREEN
	else:
		_changed_settings["fullscreen"] = DisplayServer.WINDOW_MODE_WINDOWED


# Audio Volume
func _on_master_volume_slider_value_changed(value: float) -> void:
	master_volume_label.text = str(value) + " %"
	Settings.set_master_volume(value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	music_volume_label.text = str(value) + " %"
	Settings.set_music_volume(value)


func _on_effects_volume_slider_value_changed(value: float) -> void:
	effects_volume_label.text = str(value) + " %"
	Settings.set_effects_volume(value)


# Player optics
func _on_player_color_picker_button_popup_closed() -> void:
	_changed_settings["player_line_color"] = player_color_picker.color


func _on_player_line_size_slider_value_changed(value: float) -> void:
	player_line_size_label.text = str(value) + " px"
	_changed_settings["player_line_weight"] = value


# Bullet optics
func _on_bullet_color_picker_button_popup_closed() -> void:
	_changed_settings["bullet_line_color"] = bullet_color_picker.color


func _on_bullet_line_size_slider_value_changed(value: float) -> void:
	bullet_line_size_label.text = str(value) + " px"
	_changed_settings["bullet_line_weight"] = value


# Asteroid optics
func _on_asteroid_color_picker_button_popup_closed() -> void:
	_changed_settings["asteroid_line_color"] = asteroid_color_picker.color


func _on_small_asteroid_line_size_slider_value_changed(value: float) -> void:
	small_asteroid_line_size_label.text = str(value) + " px"
	_changed_settings["asteroid_line_weight_small"] = value


func _on_medium_asteroid_line_size_slider_value_changed(value: float) -> void:
	medium_asteroid_line_size_label.text = str(value) + " px"
	_changed_settings["asteroid_line_weight_medium"] = value


func _on_large_asteroid_line_size_slider_value_changed(value: float) -> void:
	large_asteroid_line_size_label.text = str(value) + " px"
	_changed_settings["asteroid_line_weight_large"] = value


# Info texts

func _on_tab_container_mouse_entered() -> void:
	_set_info_label_text("Game might need to be restarted in order for this to take effect.")


func _on_tab_container_mouse_exited() -> void:
	_set_info_label_text("")


func _on_fullscreen_button_mouse_entered() -> void:
	_set_info_label_text("Changing this setting will restart the game!")


func _on_fullscreen_button_mouse_exited() -> void:
	_set_info_label_text("")
