extends Node2D
## Utility script containing different helper functions used throughout
##
## Autoloaded as: Util


## Valid asteroid sizes
enum AsteroidSize {
	SMALL, 
	MEDIUM,
	LARGE,
}


## Moves object exiting the screen bounds to the opposite side
func move_at_screen_bounds(
		cur_transform: Transform2D, 
		sprite_size: Vector2, 
		viewport_size: Vector2) -> Transform2D:
		
	# check if moving out of screen
	if cur_transform.origin.x < -sprite_size.x / 2:
		cur_transform.origin.x += viewport_size.x + sprite_size.x
	elif cur_transform.origin.x > viewport_size.x + sprite_size.x / 2:
		cur_transform.origin.x -= viewport_size.x+ sprite_size.x
	elif cur_transform.origin.y < -sprite_size.y / 2:
		cur_transform.origin.y += viewport_size.y + sprite_size.y
	elif cur_transform.origin.y > viewport_size.y + sprite_size.y / 2:
		cur_transform.origin.y -= viewport_size.y + sprite_size.y
		
	return cur_transform
	

## Creates a Vector2 with a random number between -n and n,
## excluding an interval of -min_speed to min_speed around zero
##
## Needed so that objects in the game never move faster or slower than
## provided values
func create_min_max_random_vector2(n: float, min_speed: float) -> Vector2:
	var v: Vector2 = Vector2.ZERO
	
	if n:
		var mx: float = randf_range(min_speed, n)
		var my: float = randf_range(min_speed, n)
		
		# randomly decide if x / y should be positive or negative
		var sign_mx: float = randf()
		var sign_my: float = randf()
		mx = mx if sign_mx > 0.5 else -mx
		my = my if sign_my > 0.5 else -my
		
		v = Vector2(mx, my)
	
	return v
	

## Creates a new offset vector based on sprite size
## 
## "within_factor" specifies the fraction of sprite_size, within which a new
## offset is generated (e.g. 2.0 -> sprite_size.x / 2.0), must be between 1 and 2
func create_random_offset_vector2(sprite_size: Vector2, within_factor: float = 2.0) -> Vector2:
	var offset: Vector2 = Vector2.ZERO
	
	var wv: float = within_factor if (within_factor > 1 or within_factor < 2) else 2.0
	
	var rnd_x = randf_range(sprite_size.x / 2, sprite_size.x / wv)
	var rnd_Y = randf_range(sprite_size.y / 2, sprite_size.y / wv)
	
	offset = Vector2(rnd_x, rnd_Y)
	
	return offset
	
	
## Check if vector does not exceed certain x and y values
## and limits the vectors x and y if exceeding
func limit_vector2(v: Vector2, upper_limit: float, lower_limit: float) -> Vector2:
	if abs(v.x) > upper_limit:
		v.x = upper_limit * signf(v.x)
	elif abs(v.x) < lower_limit:
		v.x = lower_limit * signf(v.x)
		
	if abs(v.y) > upper_limit:
		v.y = upper_limit * signf(v.y)
	elif abs(v.y) < lower_limit:
		v.y = lower_limit * signf(v.y)

	return v
	
	
## Limit a float to a specific maximum
func limit_float(f: float, upper_limit: float, lower_limit: float) -> float:
	if abs(f) > upper_limit:
		f = upper_limit * signf(f)
	elif abs(f) < lower_limit:
		f = lower_limit * signf(f)
	
	return f
	

## Estimates the rough size of a Line2D drawn object
##
## Needed so that, for example, transition at screen bounds do not
## look too janky
func estimate_object_size(points: PackedVector2Array) -> Vector2:
	var x_min: float = INF
	var x_max: float = -INF
	var y_min: float = INF
	var y_max: float = -INF
	
	for p in points:
		x_min = min(x_min, p.x)
		x_max = max(x_max, p.x)
		y_min = min(y_min, p.y)
		y_max = max(y_max, p.y)
		
	return Vector2(x_max - x_min, y_max - y_min)
	
	
## Get size of asteroid as vector2
func get_asteroid_size(base_size: Vector2, a_size: AsteroidSize) -> Vector2:
	return base_size * pow(2, float(a_size))
	

## Return correct line weight for asteroid size
func get_line_weight_for_asteroid(size: AsteroidSize) -> float:
	var line_weight: float = 1.0
	
	match size:
		AsteroidSize.SMALL:
			line_weight = Settings.game_settings.asteroid_line_weight_small
		AsteroidSize.MEDIUM:
			line_weight = Settings.game_settings.asteroid_line_weight_medium
		AsteroidSize.LARGE:
			line_weight = Settings.game_settings.asteroid_line_weight_large
	
	return line_weight
	

## Converts bpm to 1/4 note in seconds 
##
## A beat in 4/4 is a 1/4 note, so assuming all music ever has only ever
## been written in 4/4, we simply calculate BPM based on that ;-)
func bpm_to_seconds(bpm: float) -> float:
	return 60.0 / bpm


## Clamps the value to 0...100 and converts it to db
##
## Useful, b/c we want to save and display volume as 0...100, but Godot's
## own helper functions for volume conversion only work with 0...1
func volume_percent_to_db(value: float) -> float:	
	value = clampf(value, 0.0, 100.0)
	
	if value == 0:
		value = 0.01
	
	return linear_to_db(value / 100.0)
	

## Fade out music from music player node over time
##
## "play" is used to indicate wheter music should be started or stopped
## "start_volume" and "target_volume" are expected as values 0...100
@warning_ignore(return_value_discarded)
func fade_music(music_player: AudioStreamPlayer, play: bool, start_volume: float,
		target_volume: float, duration: float) -> void:
	start_volume = volume_percent_to_db(clampf(start_volume, 0.0, 100.0))
	target_volume = volume_percent_to_db(clampf(target_volume, 0.0, 100.0))
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	
	if play:
		music_player.play()
	else:
		music_player.stop()
		
	tween.tween_property(music_player, "volume_db", target_volume, duration).from(start_volume)


## Uses modulate property of node to fade in or out an element
## 
## Use with on_finished = Callable() and follow_up = false if no other action 
## should be called after fade is done
@warning_ignore(return_value_discarded)
func fade_screen_element(element: Node, fade_in: bool, duration: float,
		on_finished: Callable, follow_up: bool = true) -> void:
	var t: Tween = create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_QUART)
	
	var modulate_to: Color = Color.WHITE 
	var modulate_from: Color = Color.WHITE
	
	if fade_in:
		modulate_to.a = 1.0
		modulate_from.a = 0.0
	else:
		modulate_to.a = 0.0
		modulate_from.a = 1.0 
		
	if follow_up:
		t.finished.connect(on_finished)
	
	t.tween_property(element, "modulate", modulate_to, duration).from(modulate_from)
