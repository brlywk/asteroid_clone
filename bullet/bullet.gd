class_name Bullet
extends RigidBody2D


@export var ttl: float = 1.5 ## time to live
@export var bullet_spin_speed: float = 100
@export var laser_array: Array[Resource]


var ttl_timer: Timer


@onready var outline: Line2D = $Line2D
@onready var bullet_size: Vector2 = Util.estimate_object_size(outline.points)
@onready var viewport_size: Vector2 = get_viewport().get_visible_rect().size


# Called when the node enters the scene tree for the first time.
func _ready():
	# looks
	outline.width = Settings.game_settings.bullet_line_weight
	outline.default_color = Settings.game_settings.bullet_line_color
	
	# sound
	var random_laser: AudioStreamOggVorbis = laser_array[randi_range(0, laser_array.size()) - 1]
	$AudioPlayer.stream = random_laser
	$AudioPlayer.play()
	
	# timer
	ttl_timer = $TimeToLiveTimer
	var _t: int = ttl_timer.timeout.connect(_on_Ttl_Timer_timeout)
	ttl_timer.start(ttl)
	
	angular_velocity = bullet_spin_speed


func _physics_process(_delta: float) -> void:
	# Move over screen bounds
	var cur_transform: Transform2D = get_transform()
	var new_transform: Transform2D = Util.move_at_screen_bounds(cur_transform, bullet_size, viewport_size)
	set_transform(new_transform)


func _on_Ttl_Timer_timeout() -> void:
	queue_free()
