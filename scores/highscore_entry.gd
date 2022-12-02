class_name HighscoreEntry
extends Resource
## Single highscore entry containing player name and score


var player_name: String
var score: int
var level: int


func _init(new_player_name: String, new_score: int, new_level: int) -> void:
	player_name = new_player_name
	score = new_score 
	level = new_level
	
	
func get_entry() -> String:
	return player_name + ": " + str(score) + " (Level " + str(level) + ")"
	
