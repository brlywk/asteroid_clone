class_name HighscoreEntry
extends Resource
## Single highscore entry containing player name and score


@export var player_name: String
@export var score: int
@export var level: int


## We cannot override _init(), as this would cause "creating" the script
## file on loading (via ResourceLoader) to fail
func init(new_player_name: String, new_score: int, new_level: int) -> void:
	player_name = new_player_name
	score = new_score 
	level = new_level
