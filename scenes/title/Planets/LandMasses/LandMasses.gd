@tool
extends "res://scenes/title/Planets/Planet.gd"

func set_pixels(amount: float) -> void:
	$Water.material.set_shader_parameter("pixels", amount)
	$Land.material.set_shader_parameter("pixels", amount)
	$Cloud.material.set_shader_parameter("pixels", amount)

func set_display_size(amount: float) -> void:
	var size_vec: Vector2 = Vector2()
	size_vec.x = amount
	size_vec.y = amount
	for child: ColorRect in [$Water, $Land, $Cloud]:
		child.custom_minimum_size = size_vec
		child.offset_left = -amount / 2.0
		child.offset_top = -amount / 2.0
		child.offset_right = amount / 2.0
		child.offset_bottom = amount / 2.0

func set_light(pos: Vector2) -> void:
	$Cloud.material.set_shader_parameter("light_origin", pos)
	$Water.material.set_shader_parameter("light_origin", pos)
	$Land.material.set_shader_parameter("light_origin", pos)

func set_seed(sd: float) -> void:
	# Using fmod for safe float modulo
	var converted_seed: float = fmod(sd, 1000.0) / 100.0
	$Cloud.material.set_shader_parameter("seed", converted_seed)
	$Water.material.set_shader_parameter("seed", converted_seed)
	$Land.material.set_shader_parameter("seed", converted_seed)
	$Cloud.material.set_shader_parameter("cloud_cover", randf_range(0.35, 0.6))

func set_rotates(r: float) -> void:
	$Cloud.material.set_shader_parameter("rotation", r)
	$Water.material.set_shader_parameter("rotation", r)
	$Land.material.set_shader_parameter("rotation", r)

func update_time(t: float) -> void:
	$Cloud.material.set_shader_parameter("time", t * get_multiplier($Cloud.material as ShaderMaterial) * 0.01)
	$Water.material.set_shader_parameter("time", t * get_multiplier($Water.material as ShaderMaterial) * 0.02)
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material as ShaderMaterial) * 0.02)

func set_custom_time(t: float) -> void:
	$Cloud.material.set_shader_parameter("time", t * get_multiplier($Cloud.material as ShaderMaterial))
	$Water.material.set_shader_parameter("time", t * get_multiplier($Water.material as ShaderMaterial))
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material as ShaderMaterial))

func set_dither(d: bool) -> void:
	$Water.material.set_shader_parameter("should_dither", d)

func get_dither() -> Variant:
	return $Water.material.get_shader_parameter("should_dither")

func get_colors() -> PackedColorArray:
	# Access helper from parent class
	return get_colors_from_shader($Water.material) + get_colors_from_shader($Land.material) + get_colors_from_shader($Cloud.material)

func set_colors(colors: Array) -> void:
	# 3 Water, 4 Land, 4 Cloud = 11 Colors Total
	# Using slice() which is valid in Godot 4
	set_colors_on_shader($Water.material, colors.slice(0, 3))
	set_colors_on_shader($Land.material, colors.slice(3, 7))
	set_colors_on_shader($Cloud.material, colors.slice(7, 11))

# We can keep the randomizer here for standalone usage, 
# but BackgroundGenerator will usually override this via set_colors()
func randomize_colors() -> void:
	var seed_colors: PackedColorArray = _generate_new_colorscheme(randi() % 2 + 3, randf_range(0.7, 1.0), randf_range(0.45, 0.55))
	var land_colors: Array = []
	var water_colors: Array = []
	var cloud_colors: Array = []
	
	for i: int in range(4):
		var new_col: Color = seed_colors[0].darkened(i / 4.0)
		land_colors.append(Color.from_hsv(new_col.h + (0.2 * (i / 4.0)), new_col.s, new_col.v))
	
	for i: int in range(3):
		var new_col: Color = seed_colors[1].darkened(i / 5.0)
		water_colors.append(Color.from_hsv(new_col.h + (0.1 * (i / 2.0)), new_col.s, new_col.v))
	
	for i: int in range(4):
		var new_col: Color = seed_colors[2].lightened((1.0 - (i / 4.0)) * 0.8)
		cloud_colors.append(Color.from_hsv(new_col.h + (0.2 * (i / 4.0)), new_col.s, new_col.v))

	set_colors(water_colors + land_colors + cloud_colors)
