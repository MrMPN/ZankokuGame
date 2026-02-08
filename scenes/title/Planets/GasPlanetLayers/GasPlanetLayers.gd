extends "res://scenes/title/Planets/Planet.gd"

func set_pixels(amount: float) -> void:
	$GasLayers.material.set_shader_parameter("pixels", amount)
	# times 3 here because in this case ring is 3 times larger than planet
	$Ring.material.set_shader_parameter("pixels", amount*3.0)
	
	$GasLayers.offset_left = -amount / 2.0
	$GasLayers.offset_top = -amount / 2.0
	$GasLayers.offset_right = amount / 2.0
	$GasLayers.offset_bottom = amount / 2.0

	$Ring.offset_left = -amount * 3.0 / 2.0
	$Ring.offset_top = -amount * 3.0 / 2.0
	$Ring.offset_right = amount * 3.0 / 2.0
	$Ring.offset_bottom = amount * 3.0 / 2.0

func set_light(pos: Vector2) -> void:
	$GasLayers.material.set_shader_parameter("light_origin", pos)
	$Ring.material.set_shader_parameter("light_origin", pos)

func set_seed(sd: float) -> void:
	var converted_seed: float = fmod(sd, 1000.0)/100.0
	$GasLayers.material.set_shader_parameter("seed", converted_seed)
	$Ring.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r: float) -> void:
	$GasLayers.material.set_shader_parameter("rotation", r)
	$Ring.material.set_shader_parameter("rotation", r+0.7)

func update_time(t: float) -> void:
	$GasLayers.material.set_shader_parameter("time", t * get_multiplier($GasLayers.material as ShaderMaterial) * 0.004)
	$Ring.material.set_shader_parameter("time", t * 314.15 * 0.004)

func set_custom_time(t: float) -> void:
	$GasLayers.material.set_shader_parameter("time", t * get_multiplier($GasLayers.material as ShaderMaterial))
	$Ring.material.set_shader_parameter("time", t * 314.15 * $Ring.material.get_shader_parameter("time_speed") * 0.5)

func set_dither(d: bool) -> void:
	$GasLayers.material.set_shader_parameter("should_dither", d)

func get_dither() -> Variant:
	return $GasLayers.material.get_shader_parameter("should_dither")


func get_colors() -> PackedColorArray:
	return get_colors_from_shader($GasLayers.material) + get_colors_from_shader($GasLayers.material, "dark_colors") + get_colors_from_shader($Ring.material) + get_colors_from_shader($Ring.material, "dark_colors")

func set_colors(colors: Array) -> void:
	var cols1: Array = colors.slice(0, 3)
	var cols2: Array = colors.slice(3, 6)
	
	set_colors_on_shader($GasLayers.material, cols1)
	set_colors_on_shader($Ring.material, cols1)
	
	set_colors_on_shader($GasLayers.material, cols2, "dark_colors")
	set_colors_on_shader($Ring.material, cols2, "dark_colors")

func randomize_colors() -> void:
	var seed_colors: PackedColorArray = _generate_new_colorscheme(6 + randi() % 4, randf_range(0.3,0.55), 1.4)
	var cols: Array = []
	for i: int in 6:
		var new_col: Color = seed_colors[i].darkened(i/7.0)
		new_col = new_col.lightened((1.0 - (i/6.0)) * 0.3)
		cols.append(new_col)

	set_colors(cols)
