extends "res://scenes/title/Planets/Planet.gd"

func set_pixels(amount: float) -> void:
	$Land.material.set_shader_parameter("pixels", amount)
	$Lakes.material.set_shader_parameter("pixels", amount)
	$Clouds.material.set_shader_parameter("pixels", amount)
	
	for child: ColorRect in [$Land, $Lakes, $Clouds]:
		child.offset_left = -amount / 2.0
		child.offset_top = -amount / 2.0
		child.offset_right = amount / 2.0
		child.offset_bottom = amount / 2.0

func set_light(pos: Vector2) -> void:
	$Land.material.set_shader_parameter("light_origin", pos)
	$Lakes.material.set_shader_parameter("light_origin", pos)
	$Clouds.material.set_shader_parameter("light_origin", pos)

func set_seed(sd: float) -> void:
	var converted_seed: float = fmod(sd, 1000.0)/100.0
	$Land.material.set_shader_parameter("seed", converted_seed)
	$Lakes.material.set_shader_parameter("seed", converted_seed)
	$Clouds.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r: float) -> void:
	$Land.material.set_shader_parameter("rotation", r)
	$Lakes.material.set_shader_parameter("rotation", r)
	$Clouds.material.set_shader_parameter("rotation", r)

func update_time(t: float) -> void:
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material as ShaderMaterial) * 0.02)
	$Lakes.material.set_shader_parameter("time", t * get_multiplier($Lakes.material as ShaderMaterial) * 0.02)
	$Clouds.material.set_shader_parameter("time", t * get_multiplier($Clouds.material as ShaderMaterial) * 0.01)

func set_custom_time(t: float) -> void:
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material as ShaderMaterial))
	$Lakes.material.set_shader_parameter("time", t * get_multiplier($Lakes.material as ShaderMaterial))
	$Clouds.material.set_shader_parameter("time", t * get_multiplier($Clouds.material as ShaderMaterial))

func set_dither(d: bool) -> void:
	$Land.material.set_shader_parameter("should_dither", d)

func get_dither() -> Variant:
	return $Land.material.get_shader_parameter("should_dither")

func get_colors() -> PackedColorArray:
	return get_colors_from_shader($Land.material) + get_colors_from_shader($Lakes.material) + get_colors_from_shader($Clouds.material)

func set_colors(colors: Array) -> void:
	set_colors_on_shader($Land.material, colors.slice(0, 3))
	set_colors_on_shader($Lakes.material, colors.slice(3, 6))
	set_colors_on_shader($Clouds.material, colors.slice(6, 10))

func randomize_colors() -> void:
	var seed_colors: PackedColorArray = _generate_new_colorscheme(randi() % 2 + 3, randf_range(0.7, 1.0), randf_range(0.45, 0.55))
	var land_colors: Array = []
	var lake_colors: Array = []
	var cloud_colors: Array = []
	for i: int in 3:
		var new_col: Color = seed_colors[0].darkened(i/3.0)
		land_colors.append(Color.from_hsv(new_col.h + (0.2 * (i/4.0)), new_col.s, new_col.v))
	
	for i: int in 3:
		var new_col: Color = seed_colors[1].darkened(i/3.0)
		lake_colors.append(Color.from_hsv(new_col.h + (0.2 * (i/3.0)), new_col.s, new_col.v))
	
	for i: int in 4:
		var new_col: Color = seed_colors[2].lightened((1.0 - (i/4.0)) * 0.8)
		cloud_colors.append(Color.from_hsv(new_col.h + (0.2 * (i/4.0)), new_col.s, new_col.v))

	var final_colors: Array = []
	final_colors.append_array(land_colors)
	final_colors.append_array(lake_colors)
	final_colors.append_array(cloud_colors)
	set_colors(final_colors)
