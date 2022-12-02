class_name HighscoreList
extends Resource
## Class representing highscores list


@export var scores: Array[HighscoreEntry] = []:
	get:
		return scores
	set(_new_value):
		pass # we should not set this variable, only add scores via insert_score()


## Maximum number of allowed entries as to limit size of saved file
var _max_entries: int = 25


## Return top 10 scores to be shown in scoreboard
func get_top_ten() -> Array[HighscoreEntry]:
	if scores.size() < 10:
		return scores
	else:
		return scores.slice(0, 10)
		

## Insert a score into the list and sort scores by score descending
func insert_score(new_score: HighscoreEntry) -> void:
	scores.append(new_score)
	scores.sort_custom(_sort_by_score)
	
	# check array size and truncate if necessary
	if scores.size() >= _max_entries:
		scores = scores.slice(0, _max_entries)
	

## Custom sorting for HighscoreEntry by score
func _sort_by_score(a: HighscoreEntry, b: HighscoreEntry) -> bool:
	if a.score < b.score:
		return false
	else:
		return true
