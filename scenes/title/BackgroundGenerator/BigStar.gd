@tool
extends Sprite2D

# These variables allow the generator to control the star
var custom_speed: float = 2.0
var custom_intensity: float = 0.3
var random_offset: float = 0.0

func _ready() -> void:
	# Initial setup
	if texture:
		# We duplicate so changing one star doesn't change them all
		if not texture.resource_local_to_scene:
			texture = texture.duplicate()
		
	# Pick a random star shape
	if texture is AtlasTexture:
		texture.region.position.x = (randi() % 5) * 25.0
	
	# Random starting point for the animation
	random_offset = randf() * 100.0

func _process(delta: float) -> void:
	# Because of @tool, this runs in the Editor too!
	var t: float = Time.get_ticks_msec() / 1000.0
	var wave: float = sin(t * custom_speed + random_offset)
	
	# Map wave (-1 to 1) to a brightness dip (0 to 1)
	var dip: float = 0.5 + 0.5 * wave
	
	# Apply the intensity
	# If intensity is 0, alpha stays 1.0. If 1.0, alpha dips to 0.
	modulate.a = 1.0 - (custom_intensity * (1.0 - dip))

# This function is called by the Generator to ensure the same Seed produces the same stars
func set_rng_seed(val: int) -> void:
	# Simple pseudo-random math to pick the same texture frame every time for this seed
	var pseudo_rand: int = (val * 16807) % 2147483647
	
	if texture is AtlasTexture:
		texture.region.position.x = (pseudo_rand % 5) * 25.0
	
	# Deterministic offset
	random_offset = pseudo_rand % 100 as float
