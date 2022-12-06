extends Node2D
## Main game scene and loop


@export var new_asteroids_per_level : int = 1
@export var largest_asteroid_size: Vector2 = Vector2(64, 64)
@export var player_safe_zone_scaling: float = 3.0
@export var start_asteroid_count: int = 3


# public variables
var viewport_size : Vector2
var player_instance: PlayerShip
var player_size: Vector2
var asteroid_points: Array[int] = [20, 10, 5]
var respawning: bool = false
var game_over: bool = false
var level_ending: bool = false
var killing_asteroid: String
var _restart_timeout: int = 3


# Scenes
@onready var Player: PackedScene = preload("res://player/player_ship.tscn")
@onready var Bullet: PackedScene = preload("res://bullet/bullet.tscn")
@onready var Asteroid: PackedScene = preload("res://asteroid/asteroid.tscn")
@onready var Explosion: PackedScene = preload("res://explosion/explosion.tscn")

# UI
@onready var ui: CanvasLayer = find_child("UI")
@onready var ui_health: GridContainer = find_child("Health")
@onready var ui_score: Label = find_child("Score")
@onready var center_label: Label = find_child("CenterLabel")
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var settings_menu: ColorRect = find_child("SettingsMenu")
@onready var highscores_menu: ColorRect = find_child("HighscoresMenu")
@onready var PauseMenu: ColorRect = find_child("PauseMenu")
@onready var EnterHighscorePrompt: ColorRect = find_child("EnterHighscoreMenu")
@onready var Asteroids: Node2D = $Asteroids


@warning_ignore(return_value_discarded)
# Called when the node enters the scene tree for the first time.
func _ready():
	# connect some signals
	settings_menu.optics_changed.connect(_on_optics_settings_changed)
	
	# get viewport
	viewport_size = get_viewport().get_visible_rect().size
		
	# position player in center
	player_instance = spawn_player(viewport_size / 2)
	player_size = player_instance.ship_size
	
	# add some of those pesky asteroids
	create_asteroid(Util.AsteroidSize.LARGE, _get_random_valid_spawn_position(player_instance.position, player_size))
	create_asteroid(Util.AsteroidSize.MEDIUM, _get_random_valid_spawn_position(player_instance.position, player_size))
	create_asteroid(Util.AsteroidSize.SMALL, _get_random_valid_spawn_position(player_instance.position, player_size))
	
	# connections connections...
	GameStats.player_died.connect(_on_health_zero)
	PauseMenu.unpaused.connect(_on_pause_menu_hidden)
	EnterHighscorePrompt.score_saved.connect(_on_score_saved)
	
	
	# ui stuff
	ui.reset_ui(player_instance.outline.points)
	
	# music stuff
	Util.fade_music(music_player, true, 0.0, Settings.game_settings.music_volume, 1.0)
	
	# DEBUG scores
	#print(Scores.get_highscores())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# DEBUG: delete for "release build"
#	if OS.is_debug_build():
#		if Input.is_action_just_pressed("debug_reload"):
#			var _r = get_tree().reload_current_scene()
#			get_tree().paused = false
			
	if Input.is_action_just_pressed("ui_cancel"):
		$UI/PauseMenu.settings_menu = $UI/SettingsMenu
		$UI/PauseMenu.highscores_menu = $UI/HighscoresMenu
		get_tree().paused = true
		$UI/PauseMenu.show()
			
	# player died and is respawning
	if respawning and not game_over and Input.is_action_just_released("shoot"):
		var respawn_pos: Vector2 = viewport_size / 2
		_move_killing_asteroid(killing_asteroid, respawn_pos, player_size)
		player_instance = spawn_player(respawn_pos) # also sets respawning false
		
		get_tree().paused = false
		
		ui.hide_center_label()
		Util.fade_music(music_player, true, 0.0, Settings.game_settings.music_volume, 1.0)
		
	# skip first frame because of stupid deferred loading BS
	if not level_ending and $Asteroids.get_child_count() == 0 and Engine.get_frames_drawn() > 0:
		level_ended()
		
	if level_ending and Input.is_action_just_pressed("shoot"):
		GameStats.level += 1
		call_deferred("create_level")
		get_tree().paused = false
		ui.hide_center_label()
		
	if game_over and not respawning:
		ui.show_enter_highscore_prompt()
		
	if game_over and respawning:
		ui.show_center_label("Restarting game in " + str(_restart_timeout) + " seconds")
	

#---------- PUBLIC FUNCTIONS ----------#

func reset_game() -> void:
	# delete all asteroids
	for a in Asteroids.get_children():
		a.queue_free()
		
	# reset respawn timeout
	_restart_timeout = 3
	
	# reset player
	if is_instance_valid(player_instance):
		player_instance.queue_free()
	player_instance = spawn_player(viewport_size / 2)
		
	# create new level
	GameStats.reset_game()
	create_level()
	
	# reset UI
	ui.reset_ui(player_instance.outline.points)

	# we can play again
	game_over = false
	respawning = false
	
	# restart music
	Util.fade_music(music_player, true, 0.0, Settings.game_settings.music_volume, 1.0)
	
	# unpause game
	get_tree().paused = false
	
	
## create a new level 
func create_level() -> void:
	for i in _get_level_asteroid_count() - 1:
		create_asteroid(randi_range(0, 2), _get_random_valid_spawn_position(player_instance.position, player_size))
	create_asteroid(Util.AsteroidSize.LARGE, _get_random_valid_spawn_position(player_instance.position, player_size))
	
	level_ending = false

	
## spawns the player
func spawn_player(p_position: Vector2) -> PlayerShip:
	var p = Player.instantiate()
	p.init(music_player.stream.bpm)
	p.position = p_position
	add_child(p)
	
	p.died.connect(_on_player_died)
	respawning = false
	
	return p


## Creates a new asteroid with Asteroid Size at position
func create_asteroid(a_size: Util.AsteroidSize, a_position: Vector2,
		a_linear_velocity: Vector2 = Vector2.ZERO) -> void:
	var new_asteroid: Asteroid = Asteroid.instantiate()
	new_asteroid.init(a_size, a_linear_velocity)
			
	call_deferred("_deferred_add_asteroid", new_asteroid, a_position)
	

## makes things go boom!
func create_explosion(e_position: Vector2, e_velocity: Vector2, a_size: Util.AsteroidSize,
		is_player: bool) -> void:
	call_deferred("_deferred_create_explosion", e_position, e_velocity, a_size, is_player)
	

## helper to save some writing that one time this is used
func create_player_explosion(e_position: Vector2, e_velocity: Vector2) -> void:
	create_explosion(e_position, e_velocity, Util.AsteroidSize.MEDIUM, true)


## finished current level
func level_ended() -> void:
	get_tree().paused = true
	level_ending = true
	ui.show_center_label("Level " + str(GameStats.level) + " clear (+100 Bonus Score)!\n\nPress SPACEBAR to start next level")
	GameStats.score += GameData.level_clear_score


#---------- PRIVATE FUNCTIONS ----------#

## let's be honest, players ever really want to spawn during idle time...
func _deferred_spawn_player(p_position: Vector2) -> PlayerShip:
	return spawn_player(p_position)


## create deferred explosion... the most dangerous kind of explosion!
func _deferred_create_explosion(e_position: Vector2, e_velocity: Vector2, a_size: Util.AsteroidSize,
		is_player: bool) -> void:
	var kaboom = Explosion.instantiate()
	kaboom.position = e_position
	kaboom.linear_velocity = e_velocity / 2
	kaboom.z_index = 3
	add_child(kaboom)
	kaboom.go_boom(a_size, is_player)


# add new asteroid deferred...
func _deferred_add_asteroid(new_asteroid: Asteroid, a_position: Vector2) -> void:
	$Asteroids.add_child(new_asteroid)
	new_asteroid.position = a_position
	var _d = new_asteroid.destroyed.connect(_on_Asteroid_destroyed)


## creates a random point within viewport
func _create_random_spawn_vector2(p_size: Vector2) -> Vector2:
	var rnd_x = randf_range(p_size.x, viewport_size.x - p_size.x)
	var rnd_y = randf_range(p_size.y, viewport_size.y - p_size.y)
	return Vector2(rnd_x, rnd_y)


## creates a random valid spawn position for asteroids, i.e. outside of player "safe zone"
func _get_random_valid_spawn_position(p_position: Vector2, p_size: Vector2) -> Vector2:
	# safe zone size around player on asteroid spawn
	var safe_zone_size: float = (p_size.x * player_safe_zone_scaling) + largest_asteroid_size.x
#
#	# random coordinates
	var asteroid_spawn_point: Vector2 = _create_random_spawn_vector2(p_size)

	while (asteroid_spawn_point - p_position).length() <= safe_zone_size:
		asteroid_spawn_point = _create_random_spawn_vector2(p_size)
	
	
	return asteroid_spawn_point
	

## move asteroid that killed player to a new position
## (needed if player is killed close to center of screen)
## TODO: should maybe be changed into "move asteroids away from center", someday...
func _move_killing_asteroid(n: String, p_position: Vector2, p_size: Vector2) -> void:
	var a: Asteroid = $Asteroids.get_node(n)
	if a:
		a.position = _get_random_valid_spawn_position(p_position, p_size)
	
	
## get new asteroids for current level
func _get_level_asteroid_count() -> int:
	return (start_asteroid_count - 1) + new_asteroids_per_level * GameStats.level
	

#---------- SIGNAL HANDLERS ----------#

## asteroid goes boom!
func _on_Asteroid_destroyed(a_size: Util.AsteroidSize, a_position: Vector2, 
		a_linear_velocity: Vector2) -> void:
	# increase player score
	GameStats.score += GameData.asteroid_scores[a_size]
	
	# E X P L O S I O N S ! ! !
	create_explosion(a_position, a_linear_velocity, a_size, false)
	
	# spawn new asteroids
	if a_size > Util.AsteroidSize.SMALL:
		create_asteroid(a_size - 1, a_position, a_linear_velocity.rotated(randf_range(0, 2 * PI)))
		create_asteroid(a_size - 1, a_position, a_linear_velocity.rotated(randf_range(0, 2 * PI)))
				


# player dead! :-(
func _on_player_died(p_position: Vector2, p_velocity: Vector2, name_of_killer: String) -> void:
	killing_asteroid = name_of_killer
	
	# stop music
	Util.fade_music(music_player, false, Settings.game_settings.music_volume, 0.0, 0.5)
	
	# player goes boom
	create_player_explosion(p_position, p_velocity)
	GameStats.player_health -= 1
	
	# pause game and show respawn label
	get_tree().paused = true	
	if not game_over:
		ui.show_center_label("Press SPACEBAR to respawn")
		respawning = true


## player dead-dead! x_x
func _on_health_zero() -> void:
	game_over = true	
	

## game settings regarding look of opjects changed
func _on_optics_settings_changed(changes: Dictionary) -> void:
	if not changes.is_empty():
		# Note: we're not bothering with changing bullet settings, as bullets
		# are instanciated anew with every shot anyway
		for key in changes:
			# HACK: Not the best way to do this, as this assumes my naming
			# scheme is 100 % consistent...
			var prop: String = "default_color" if key.contains("color") else "width"
			
			if key.contains("player"):
				player_instance.get_node("Line2D").set(prop, changes[key])
			if key.contains("asteroid"):
				for a in Asteroids.get_children():
					a.get_node("Line2D").set(prop, changes[key])
	
	
func _on_music_player_finished() -> void:
	Util.fade_music(music_player, true, 0.0, Settings.game_settings.music_volume, 0.01)
	
	
func _on_pause_menu_hidden() -> void:
	## yes, it could also just say !game_over, but this is more readable
	var still_paused: bool = game_over or respawning
	get_tree().paused = still_paused


func _on_score_saved() -> void:
	EnterHighscorePrompt.hide()
	respawning = true
	%GameResetTimer.start()


func _on_reset_timeout() -> void:
	if _restart_timeout > 0:
		ui.show_center_label("Restarting game in " + str(_restart_timeout) + " seconds")
		_restart_timeout -= 1
	else:
		%GameResetTimer.stop()
		ui.hide_center_label()
		reset_game()
