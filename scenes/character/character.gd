extends AnimatedSprite2D

@export var speed: float = 100.0

func _process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	
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
