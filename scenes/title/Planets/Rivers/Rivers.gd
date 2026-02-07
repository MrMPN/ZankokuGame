@tool
extends "res://Planets/Planet.gd"

# Cache for editor safety
var _cached_seed: float = 0.0
var _cached_colors: Array = []

func _ready():
	super._ready()
	if has_node("Land"):
		set_seed(_cached_seed)
		if not _cached_colors.is_empty():
			set_colors(_cached_colors)

func set_pixels(amount):
	if not has_node("Land"): return
	$Land.material.set_shader_parameter("pixels", amount)
	$Cloud.material.set_shader_parameter("pixels", amount)

func set_light(pos):
	if not has_node("Land"): return
	$Cloud.material.set_shader_parameter("light_origin", pos)
	$Land.material.set_shader_parameter("light_origin", pos)

func set_seed(sd):
	_cached_seed = sd
	if not has_node("Land"): return
	
	var converted_seed = fmod(sd, 1000.0) / 100.0
	$Cloud.material.set_shader_parameter("seed", converted_seed)
	$Cloud.material.set_shader_parameter("cloud_cover", randf_range(0.35, 0.6))
	$Land.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r):
	if not has_node("Land"): return
	$Cloud.material.set_shader_parameter("rotation", r)
	$Land.material.set_shader_parameter("rotation", r)

func update_time(t):
	if not has_node("Land"): return
	$Cloud.material.set_shader_parameter("time", t * get_multiplier($Cloud.material) * 0.01)
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material) * 0.02)

func set_custom_time(t):
	if not has_node("Land"): return
	$Cloud.material.set_shader_parameter("time", t * get_multiplier($Cloud.material) * 0.5)
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material))

func set_dither(d):
	if not has_node("Land"): return
	$Land.material.set_shader_parameter("should_dither", d)

func get_dither():
	if not has_node("Land"): return false
	return $Land.material.get_shader_parameter("should_dither")

func get_colors():
	if not has_node("Land"): return []
	return get_colors_from_shader($Land.material) + get_colors_from_shader($Cloud.material)

func set_colors(colors):
	_cached_colors = colors
	if not has_node("Land"): return
	
	# LandMass expects 10 colors (6 Land + 4 Cloud)
	if colors.size() >= 10:
		set_colors_on_shader($Land.material, colors.slice(0, 6))
		set_colors_on_shader($Cloud.material, colors.slice(6, 10))
