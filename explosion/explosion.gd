class_name Explosion
extends RigidBody2D


@export var small_explosions: Array[Resource]
@export var medium_explosions: Array[Resource]
@export var large_explosions: Array[Resource]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect audistream
	var _f = $AudioPlayer.finished.connect(_on_AudioPlayer_finished)
	
	
func go_boom(a_size: Util.AsteroidSize, is_player: bool = false) -> void:
	var explosion_array: Array
	var explosion_color: Color
	
	# what's gonna do the exploding?
	if is_player:
		explosion_array = medium_explosions
		explosion_color = Settings.game_settings.player_line_color
	else:
		match a_size:
			Util.AsteroidSize.SMALL:
				explosion_array = small_explosions
			Util.AsteroidSize.MEDIUM:
				explosion_array = medium_explosions
			Util.AsteroidSize.LARGE:
				explosion_array = large_explosions
		explosion_color = Settings.game_settings.asteroid_line_color
		
	# set explosion color to selected color and create gradient for maximum coolness
	var start_color: Color = explosion_color
	var end_color: Color = explosion_color
	end_color.a = 0.0
	var explosion_gradient: PackedColorArray = [start_color, end_color]
	
	$Particles.process_material.color_ramp.gradient.colors = explosion_gradient

	# get size for random function
	var explosion_sound: AudioStreamOggVorbis = explosion_array[randi_range(0, explosion_array.size() - 1)]
	$AudioPlayer.stream = explosion_sound
	
	$Particles.lifetime = $AudioPlayer.stream.get_length()
	$Particles.scale *= pow(2, float(a_size))
	
	$AudioPlayer.play()
	$Particles.emitting = true
	

func _on_AudioPlayer_finished() -> void:
	queue_free()

