class_name Asteroid
extends RigidBody2D


signal destroyed(asteroid_size: Util.AsteroidSize, a_position: Vector2, a_velocity: Vector2)


@export_group("Generator Settings")
@export var base_size: float = 16.0 ## Size of smallest Asteroid
@export_range(0.01, 0.25, 0.001) var shape_factor: float = 0.2
@export var small_asteroid_min_max_point_count: Vector2 = Vector2(10, 14)
@export var medium_asteroid_min_max_point_count: Vector2 = Vector2(14, 20)
@export var large_asteroid_min_max_point_count: Vector2 = Vector2(20, 32)

@export_group("Behaviour")        
@export_range(0, 360, 1) var max_angular_velocity: float = 45
@export_range(0.0, 100.0, 0.1) var min_speed: float = 25.0
@export_range(0.0, 500.0, 0.1) var max_speed: float = 100.0


var asteroid_size: Util.AsteroidSize
var outline_size: Vector2 = Vector2(base_size, base_size)
var min_and_max_points: Array ## min and max values in Vector2 for Small, Medium, Large


## CALL IMMEDIATELY AFTER INSTANTIATING
func init(a_size: Util.AsteroidSize, a_velocity: Vector2) -> void:
	asteroid_size = a_size
	linear_velocity = a_velocity
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var outline: Line2D = $Line2D
	
	# get minium and maximum values for number of points in asteroids
	min_and_max_points = [
		small_asteroid_min_max_point_count,
		medium_asteroid_min_max_point_count,
		large_asteroid_min_max_point_count
	]
	
	# security check
	if not asteroid_size:
		asteroid_size = Util.AsteroidSize.SMALL
			
	# small = base * 2^0, medium = base * 2^1 etc.
	outline_size = Util.get_asteroid_size(outline_size, asteroid_size)
	
	# decide point count
	var min_pt: float = min_and_max_points[asteroid_size].x
	var max_pt: float = min_and_max_points[asteroid_size].y
	var point_count: int = ceili(randf_range(min_pt, max_pt))
	
	# create shape
	var a_shape: PackedVector2Array = _generate_random_shape(outline_size, point_count)
	outline.points = a_shape
	
	$Collider.polygon = a_shape
	$Area2D/Colider.polygon = a_shape
	
	# setting up 'em optics
	outline.default_color = Settings.game_settings.asteroid_line_color
	outline.width = Util.get_line_weight_for_asteroid(asteroid_size)
	
	# connections connections...
	var _c: int = $Area2D.body_entered.connect(_on_body_entered)
	
	# assign linear velocity for newly created asteroids
	if linear_velocity == Vector2.ZERO:
		linear_velocity = Util.create_min_max_random_vector2(max_speed, min_speed)
	
	# assign random angular velocity to make asteroid spin
	angular_velocity = randf_range(deg_to_rad(-max_angular_velocity), deg_to_rad(max_angular_velocity))
	

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# handle moving over screen bounds
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var cur_transform: Transform2D = state.get_transform()
	var new_transform: Transform2D = Util.move_at_screen_bounds(cur_transform, outline_size, viewport_size)
	state.set_transform(new_transform)
	
	# check that asteroid doesn't exceed max speed... no zoomies for them!
	# ... and no slow pokes either!
	state.linear_velocity = Util.limit_vector2(state.linear_velocity, max_speed, min_speed)
	state.angular_velocity = Util.limit_float(state.angular_velocity, max_angular_velocity, -INF)
	
	
#---------- PRIVATE FUNCTIONS ----------#

## Generates Vector2Array to be used as shape for Line2D and CollisionPolygons
func _generate_random_shape(size: Vector2, point_count: int) -> PackedVector2Array:
	# let's do the math thingy! 
	# draw points evenly spaced on a circle with radius size / 2
	var radius: Vector2 = Vector2(size.x / 2, 0.0)
	var center: Vector2 = Vector2.ZERO
	
	var spacing = 2 * PI / point_count
	var temp_point_array: Array = []
	
	for i in range(point_count):
		# calculate point
		var point_pos: Vector2 = center + radius.rotated(spacing * i)
		
		# we don't really care about exact sizes, as the colliders will get the same shape		
		point_pos = _get_offset_point(point_pos, size, shape_factor)
		temp_point_array.push_back(point_pos)
		
	# push first point into array again to close line
	temp_point_array.push_back(temp_point_array[0])
		
	# create the convex hull to make sure colliders work
	var point_array = PackedVector2Array(temp_point_array)
	point_array = Geometry2D.convex_hull(point_array)
	
	# NOTE: 
	# due to using convex hull to determine the final shape,
	# the origin point of the asteroid can be off-centered by quite a bit
		
	return point_array
	

## creates offset points based on the provided "shape factor" (which is really
## just a coefficient)
func _get_offset_point(v: Vector2, o: Vector2, factor: float) -> Vector2:
	var point_offset_x: float = randf_range(-o.x * factor, o.x * factor)
	var point_offset_y: float = randf_range(-o.x * factor, o.x * factor)
	var point_offset: Vector2 = Vector2(point_offset_x, point_offset_y)
	
	return Vector2(v.x + point_offset.x, v.y + point_offset_y)


#---------- SIGNAL HANDLERS ----------#
	
func _on_body_entered(body: Node2D) -> void:
	queue_free()
	body.queue_free()
	destroyed.emit(asteroid_size, position, linear_velocity)
	
