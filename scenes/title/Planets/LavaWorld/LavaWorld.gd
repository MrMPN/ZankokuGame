extends "res://scenes/title/Planets/Planet.gd"

func set_pixels(amount: float) -> void:
	$Land.material.set_shader_parameter("pixels", amount)
	$Craters.material.set_shader_parameter("pixels", amount)
	$LavaRivers.material.set_shader_parameter("pixels", amount)
	
	for child: ColorRect in [$Land, $Craters, $LavaRivers]:
		child.offset_left = -amount / 2.0
		child.offset_top = -amount / 2.0
		child.offset_right = amount / 2.0
		child.offset_bottom = amount / 2.0
	
func set_light(pos: Vector2) -> void:
	$Land.material.set_shader_parameter("light_origin", pos)
	$Craters.material.set_shader_parameter("light_origin", pos)
	$LavaRivers.material.set_shader_parameter("light_origin", pos)

func set_seed(sd: float) -> void:
	var converted_seed: float = fmod(sd, 1000.0)/100.0
	$Land.material.set_shader_parameter("seed", converted_seed)
	$Craters.material.set_shader_parameter("seed", converted_seed)
	$LavaRivers.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r: float) -> void:
	$Land.material.set_shader_parameter("rotation", r)
	$Craters.material.set_shader_parameter("rotation", r)
	$LavaRivers.material.set_shader_parameter("rotation", r)

func update_time(t: float) -> void:
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material as ShaderMaterial) * 0.02)
	$Craters.material.set_shader_parameter("time", t * get_multiplier($Craters.material as ShaderMaterial) * 0.02)
	$LavaRivers.material.set_shader_parameter("time", t * get_multiplier($LavaRivers.material as ShaderMaterial) * 0.02)

func set_custom_time(t: float) -> void:
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material as ShaderMaterial))
	$Craters.material.set_shader_parameter("time", t * get_multiplier($Craters.material as ShaderMaterial))
	$LavaRivers.material.set_shader_parameter("time", t * get_multiplier($LavaRivers.material as ShaderMaterial))

func set_dither(d: bool) -> void:
	$Land.material.set_shader_parameter("should_dither", d)

func get_dither() -> Variant:
	return $Land.material.get_shader_parameter("should_dither")

func get_colors() -> PackedColorArray:
	return get_colors_from_shader($Land.material) + get_colors_from_shader($Craters.material) + get_colors_from_shader($LavaRivers.material)

func set_colors(colors: Array) -> void:
	set_colors_on_shader($Land.material, colors.slice(0, 3))
	set_colors_on_shader($Craters.material, colors.slice(3, 5))
	set_colors_on_shader($LavaRivers.material, colors.slice(5, 8))

func randomize_colors() -> void:
	var seed_colors: PackedColorArray = _generate_new_colorscheme(randi() % 3 + 2, randf_range(0.6, 1.0), randf_range(0.7, 0.8))
	var land_colors: Array = []
	var lava_colors: Array = []
	for i: int in 3:
		var new_col: Color = seed_colors[0].darkened(i / 3.0)
		land_colors.append(Color.from_hsv(new_col.h + (0.2 * (i / 4.0)), new_col.s, new_col.v))
	
	for i: int in 3:
		var new_col: Color = seed_colors[1].darkened(i / 3.0)
		lava_colors.append(Color.from_hsv(new_col.h + (0.2 * (i / 3.0)), new_col.s, new_col.v))

	var final_colors: Array = []
	final_colors.append_array(land_colors)
	final_colors.append(land_colors[1])
	final_colors.append(land_colors[2])
	final_colors.append_array(lava_colors)
	set_colors(final_colors)
