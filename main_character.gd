extends AnimatedSprite2D

@export var speed: float = 100.0
@export var movement_enabled: bool = false
@export var target_node_path: NodePath
var target_node: Node2D

func _ready() -> void:
	print("MainCharacter ready. target_node_path: ", target_node_path)
	if target_node_path:
		target_node = get_node(target_node_path)
		if target_node:
			print("MainCharacter successfully found target_node: ", target_node.name)
		else:
			print("MainCharacter FAILED to find target_node at path: ", target_node_path)
	else:
		print("MainCharacter has no target_node_path set")

var _moving_to_target: bool = false

func _process(delta: float) -> void:
	if _moving_to_target and target_node:
		print("Got here and")
		var target_pos: Vector2 = target_node.position
		var direction: Vector2 = (target_pos - position).normalized()
		var distance: float = position.distance_to(target_pos)
		
		if distance > 2.0: # Small threshold to avoid jittering
			position += direction * speed * delta
			play_walk_animation(direction)
		else:
			position = target_pos
			_moving_to_target = false
			stop()
		return

	if not movement_enabled:
		stop()
		return
		
	var direction: Vector2 = Vector2.ZERO
	direction.normalized()
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
		
	if direction.length() > 0:
		direction = direction.normalized()
		position += direction * speed * delta
		play_walk_animation(direction)
	else:
		stop()

func play_walk_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		# Horizontal movement
		play("walk_right")
		flip_h = direction.x < 0
	else:
		# Vertical movement
		flip_h = false
		if direction.y > 0:
			play("walk_down")
		else:
			play("walk_up")

func toggle_movement() -> void:
	movement_enabled = !movement_enabled

func move_to_target_node() -> void:
	print("move_to_target_node called")
	print("target_node_path value: ", target_node_path)
	
	# Attempt to re-resolve if null
	if not target_node and target_node_path:
		print("target_node is null, attempting to resolve again...")
		target_node = get_node_or_null(target_node_path)
	
	print("target_node value: ", target_node)
	if target_node:
		print("Target node is set to: ", target_node.name)
		_moving_to_target = true
	else:
		print("Error: target_node is NOT set. Tried path: ", target_node_path)
