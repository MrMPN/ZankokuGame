extends Node2D

@export var flight_time: float = 60.0 # Time in seconds for one flight
@export var target_node: Node2D
@export var arc_height: float = 150.0
@export var sprite_rotation_offset: float = 0.0 # Additional rotation in degrees

var start_position: Vector2
var target_position: Vector2
var control_point: Vector2
var progress: float = 0.0

func _ready() -> void:
	if target_node:
		target_position = target_node.global_position
	else:
		# Fallback to a default if not set
		target_position = Vector2(467, 300)

	# Initial position off-screen left
	start_position = Vector2(-100, get_viewport_rect().size.y * 0.7)
	position = start_position
	
	# Create a control point for the Bezier arc
	# It's roughly in the middle but offset upwards
	var mid_point: Vector2 = (start_position + target_position) / 2.0
	control_point = mid_point + Vector2(0, -arc_height)
	
	$Spaceship.play("default")

func _process(delta: float) -> void:
	progress += delta / flight_time
	
	if progress > 1.0:
		hide()
		set_process(false)
		return

	# Quadratic Bezier formula: (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
	# We use smoothstep to make the movement start and end slower (easing)
	var t: float = smoothstep(0.0, 1.0, progress)
	# Also use a curve for scale so it gets smaller faster as it gets "further"
	var t_scale: float = pow(t, 1.5) 
	
	var q0: Vector2 = start_position.lerp(control_point, t)
	var q1: Vector2 = control_point.lerp(target_position, t)
	var next_pos: Vector2 = q0.lerp(q1, t)
	
	# Calculate direction to rotate the spaceship
	var look_direction: Vector2 = (next_pos - position).normalized()
	if look_direction != Vector2.ZERO:
		# The sprite is rotated 90 degrees in the tscn (rotation = 1.5707964)
		# which means its "front" is facing down in its local space.
		# Angle 0 is right. We want the "front" (down) to face the look_direction.
		# look_direction.angle() gives the angle to face right.
		# We subtract PI/2 to align the sprite's local "down" (front) with look_direction.
		rotation = look_direction.angle() - PI/2.0 + deg_to_rad(sprite_rotation_offset)
	
	position = next_pos
	
	# Scaling down as it approaches the planet (simulating distance)
	# Start at scale 1.0, end at 0.1
	var s: float = lerp(1.0, 0.1, t_scale)
	scale = Vector2(s, s)
