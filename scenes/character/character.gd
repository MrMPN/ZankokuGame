extends CharacterBody2D

@export var speed: float = 100.0
@export var stop_delay: float = 0.1 # Seconds to wait before stopping animation after input release

var _idle_timer: float = 0.0
@onready var sprite: AnimatedSprite2D = $Sprite

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
		
	if direction.length() > 0.0:
		direction = direction.normalized()
		velocity = direction * speed
		play_walk_animation(direction)
		_idle_timer = stop_delay
	else:
		velocity = Vector2.ZERO
		if _idle_timer > 0:
			_idle_timer -= delta
			if _idle_timer <= 0:
				if sprite.is_playing():
					sprite.stop()
					sprite.frame = 0
		elif sprite.is_playing():
			# This handles the case where stop_delay might be 0
			sprite.stop()
			sprite.frame = 0

	move_and_slide()

func play_walk_animation(direction: Vector2) -> void:
	var new_anim: StringName = sprite.animation
	if abs(direction.x) > abs(direction.y):
		new_anim = "walk_right"
		sprite.flip_h = direction.x < 0
	elif abs(direction.y) > abs(direction.x):
		new_anim = "walk_down" if direction.y > 0 else "walk_up"
		sprite.flip_h = false
	
	if sprite.animation != new_anim:
		# Save current frame to keep the walk cycle synchronized across directions
		var current_frame: int = sprite.frame
		sprite.play(new_anim)
		# Ensure we don't snap to a different leg phase if the animation was stopped
		if current_frame != 0:
			sprite.frame = current_frame
	elif not sprite.is_playing():
		sprite.play()
