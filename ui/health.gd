extends GridContainer


@export var current_health: int:
	get:
		return current_health
	set(new_value):
		current_health = new_value
		_render_health(current_health)


var player_health_icon_shape: PackedVector2Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# the way I do it (which is probably sketchy at best), I can only add the
	# health display after everything else is loaded, so a deferred call it is
	call_deferred("_deferred_add_health_ui")


## Add health UI (deferred)
func _deferred_add_health_ui() -> void:
	# get shape from player node
	current_health = GameData.player_start_lives
	
	
## creates the actual health icons to display
func _create_health_icon(shape: PackedVector2Array, number: int) -> Control:
	if not number:
		number = 0
	
	# Create HealthIcon
	var health_icon: Control = Control.new()
	health_icon.name = "HealthIcon_" + str(number)
	
	# Add Line2D to HealthIcon
	var line: Line2D = Line2D.new()
	line.name = "Line2D"
	line.points = shape
	line.width = Settings.game_settings.player_health_line_weight
	line.set_scale(Vector2(0.75, 0.75))
	line.rotation = -PI / 2
	line.position = Vector2(16, 16)
	
	health_icon.add_child(line)
	
	return health_icon
	
	
## sets the player health (totally unexpected!)
func _render_health(new_health: int) -> void:
	var current_health_display_count: int = self.get_child_count()
	
	# add player health icon
	if current_health_display_count < new_health:
		for i in range(current_health_display_count, new_health):
			var health_icon: Control = _create_health_icon(player_health_icon_shape, i)
			health_icon.custom_minimum_size = Vector2(24, 24) # hard-coded, should be based on size of line2D
			self.add_child(health_icon)
			
	# remove player health icon
	if current_health_display_count > new_health:
		for i in range(new_health, current_health_display_count):
			var health_icon: Control = get_child(new_health)
			self.remove_child(health_icon)
	
	
## little helper to render initial UI with global settings
func _render_initial_health() -> void:
	_render_health(GameData.player_start_lives)
