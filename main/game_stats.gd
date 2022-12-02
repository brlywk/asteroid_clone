extends Node
## Class that captures all stats for a running game, like health and score
## 
## This should better be done in separat health and score tracking classes,
## but this should suffice for the current "scope"
##
## Autoloaded as: GameStats


signal player_health_changed(old_value: int, new_value: int)
signal player_died
signal score_changed(new_value: int)
signal level_changed(new_level: int)


var player_health: int = GameData.player_start_lives:
	get:
		return player_health
	set(new_value):
		_player_health_change(player_health, new_value)
		new_value = clampi(new_value, 0, GameData.player_maximum_lives)
		player_health = new_value
		
var score: int = 0:
	get:
		return score
	set(new_value):
		score = new_value
		score_changed.emit(new_value)
		
var level: int = 1:
	get:
		return level
	set(new_value):
		level = new_value
		_check_for_extra_life()
		level_changed.emit(level)
		
		
func reset_game() -> void:
	player_health = GameData.player_start_lives
	score = 0
	level = 1
		

func _player_health_change(old_value: int, new_value: int) -> void:
	# player health changed, so emit that signal
	player_health_changed.emit(old_value, new_value)
	
	if new_value == 0:
		player_died.emit()
	if new_value > GameData.player_maximum_lives:
		score += GameData.overhealth_score
		
		
func _check_for_extra_life() -> void:
	if level % GameData.cleared_levels_for_extra_life == 0:
		player_health += 1
	
