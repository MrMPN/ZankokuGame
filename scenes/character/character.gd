extends AnimatedSprite2D

@export var speed: float = 100.0
@export var stop_delay: float = 0.1 # Seconds to wait before stopping animation after input release

var _idle_timer: float = 0.0

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
		_idle_timer = stop_delay
	else:
		if _idle_timer > 0:
			_idle_timer -= delta
			if _idle_timer <= 0:
				if is_playing():
					stop()
					frame = 0
		elif is_playing():
			# This handles the case where stop_delay might be 0
			stop()
			frame = 0

func play_walk_animation(direction: Vector2) -> void:
	var new_anim: StringName = animation
	if abs(direction.x) > abs(direction.y):
		new_anim = "walk_right"
		flip_h = direction.x < 0
	elif abs(direction.y) > abs(direction.x):
		new_anim = "walk_down" if direction.y > 0 else "walk_up"
		flip_h = false
	
	if animation != new_anim:
		# Save current frame to keep the walk cycle synchronized across directions
		var current_frame: int = frame
		var current_progress: int = frame_progress
		play(new_anim)
		# Ensure we don't snap to a different leg phase if the animation was stopped
		if current_frame != 0 or current_progress > 0:
			frame = current_frame
			frame_progress = current_progress
	elif not is_playing():
		play()
