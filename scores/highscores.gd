extends Node
## Class handling laoding and saving of highscore data
##
## Autoloaded as: Scores

var highscores: HighscoreList
var highscores_path: String = ProjectSettings.globalize_path("user://highscores.tres")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ResourceLoader.exists(highscores_path):
		highscores = ResourceLoader.load(highscores_path) as HighscoreList
	else:
		highscores = HighscoreList.new()


@warning_ignore(return_value_discarded)
## Saves current highscores to disk
func save_highscores() -> void:
	ResourceSaver.save(highscores, highscores_path)
	

## Adds a new highscore to the highscores list and saves it
func add_highscore(player_name: String, new_score: int, new_level: int) -> void:
	var new_entry: HighscoreEntry = HighscoreEntry.new()
	new_entry.init(player_name, new_score, new_level)
		
	highscores.insert_score(new_entry)
	save_highscores()


## Gets a String-Array with current top 10 highscores
func get_highscores() -> Array[String]:
	var printed_highscores: Array[String] = []
	
	for score in highscores.get_top_ten():
		printed_highscores.append(score.get_entry())
		
	return printed_highscores
