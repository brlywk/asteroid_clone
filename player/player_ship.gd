class_name PlayerShip
extends CharacterBody2D
## Main player class


signal died(p_position: Vector2, p_velocity: Vector2, killer: Node2D)


@export var speed: int = 200
@export var rotation_speed: float = 6
@export var bullet_speed: float = 300 
@export var bullet_cooldown: float = 0.25


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var PlayerBullet: Resource = preload("res://bullet/bullet.tscn")
var bullet_timer: Timer
var can_shoot: bool = true
var song_bpm: float


@onready var outline: Line2D = $Line2D
@onready var ship_size: Vector2 = Util.estimate_object_size(outline.points)
@onready var animation_player: AnimationPlayer = $ThrustAnimationPlayer
@onready var thrust_outline: Line2D = $ThrustLine


## CALL THIS FIRST OR DIE!
func init(bpm: float) -> void:
	if bpm:
		song_bpm = bpm
	else:
		song_bpm = 100.0
	
	var quarter_note = Util.bpm_to_seconds(song_bpm)
	bullet_cooldown *= quarter_note


func _ready() -> void:
	outline.default_color = Color(Settings.game_settings.player_line_color)
	outline.width = Settings.game_settings.player_line_weight
	thrust_outline.default_color = Color(Settings.game_settings.player_line_color)
	thrust_outline.width = Settings.game_settings.player_line_weight
	thrust_outline.visible = false
	
	bullet_timer = $BulletTimer
	var _t: int = bullet_timer.timeout.connect(_on_Bullet_Timer_timeout)
	
	# connect area2d collision
	var _c: int = $Area2D.body_entered.connect(_on_body_entered)
	

func _physics_process(delta: float) -> void:
	var rotation_dir: int = 0
	var add_velocity: Vector2 = Vector2.ZERO
	
	# Movement
	if Input.is_action_pressed("rotate_left"):
		rotation_dir -= 1
	if Input.is_action_pressed("rotate_right"):
		rotation_dir += 1
	if Input.is_action_pressed("speed_up"):
		add_velocity += transform.x * speed
		thrust_outline.visible = true
		animation_player.play("Thrust")
		
	rotation += rotation_dir * rotation_speed * delta
	velocity += add_velocity * delta
	var _m: bool = move_and_slide()
	
	# Move over screen bounds
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var cur_transform: Transform2D = get_transform()
	var new_transform: Transform2D = Util.move_at_screen_bounds(cur_transform, ship_size, viewport_size)
	set_transform(new_transform)
	
	# Shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		can_shoot = false
		var bullet = PlayerBullet.instantiate()
		var offset: Vector2 = Vector2(ship_size.x / 2, 0.0)
		bullet.position = position + offset.rotated(rotation)
		bullet.rotation = rotation
		bullet.linear_velocity = velocity + Vector2(bullet_speed, 0).rotated(rotation)
		get_parent().add_child(bullet)
		bullet_timer.start(bullet_cooldown)


## bullet timer
func _on_Bullet_Timer_timeout() -> void:
	can_shoot = true
	

## collision with asteroid
func _on_body_entered(body: Node2D) -> void:
	print("Hit at " + str(position) + " by  " + str(body.name))
	died.emit(position, velocity, body.name)
	queue_free()
