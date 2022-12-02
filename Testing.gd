extends Node2D

var read_only_prop: int = 42:
	get:
		return read_only_prop
	set(_new_value):
		pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var int_a: int = 42
	var int_b: int = 42
	var int_c: int = 75
	
	print(_same(int_a, 42))
	
	
func _same(a: Variant, b: Variant) -> bool:
	return a == b
