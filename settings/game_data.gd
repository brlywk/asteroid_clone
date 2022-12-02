extends Node
## Various values and settings the game uses throughout
##
## Autoloaded as: GameData


# Player
var player_start_lives: int = 3
var player_lives_per_level: int = 1
var player_maximum_lives: int = 6

# Scores
var small_score: int = 20
var medium_score: int = 10
var large_score: int = 5
var level_clear_score: int = 100
var overhealth_score: int = 100
var cleared_levels_for_extra_life: int = 3

# asteroid scores array for convenience
var asteroid_scores: Array[int] = [small_score, medium_score, large_score]
