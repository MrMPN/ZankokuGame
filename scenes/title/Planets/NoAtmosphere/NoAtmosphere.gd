@tool
extends "res://scenes/title/Planets/Planet.gd"

func set_pixels(amount: float) -> void:
	$Ground.material.set_shader_parameter("pixels", amount)
	$Craters.material.set_shader_parameter("pixels", amount)

	for child: ColorRect in [$Ground, $Craters]:
		child.offset_left = -amount / 2.0
		child.offset_top = -amount / 2.0
		child.offset_right = amount / 2.0
		child.offset_bottom = amount / 2.0

func set_light(pos: Vector2) -> void:
	$Ground.material.set_shader_parameter("light_origin", pos)
	$Craters.material.set_shader_parameter("light_origin", pos)

func set_seed(sd: float) -> void:
	var converted_seed: float = fmod(sd, 1000.0)/100.0
	$Ground.material.set_shader_parameter("seed", converted_seed)
	$Craters.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r: float) -> void:
	$Ground.material.set_shader_parameter("rotation", r)
	$Craters.material.set_shader_parameter("rotation", r)

func update_time(t: float) -> void:
	$Ground.material.set_shader_parameter("time", t * get_multiplier($Ground.material as ShaderMaterial) * 0.02)
	$Craters.material.set_shader_parameter("time", t * get_multiplier($Craters.material as ShaderMaterial) * 0.02)

func set_custom_time(t: float) -> void:
	$Ground.material.set_shader_parameter("time", t * get_multiplier($Ground.material as ShaderMaterial))
	$Craters.material.set_shader_parameter("time", t * get_multiplier($Craters.material as ShaderMaterial))

func set_dither(d: bool) -> void:
	$Ground.material.set_shader_parameter("should_dither", d)

func get_dither() -> Variant:
	return $Ground.material.get_shader_parameter("should_dither")

func get_colors() -> PackedColorArray:
	return get_colors_from_shader($Ground.material) + get_colors_from_shader($Craters.material)

func set_colors(colors: Array) -> void:
	set_colors_on_shader($Ground.material, colors.slice(0, 3))
	set_colors_on_shader($Craters.material, colors.slice(3, 5))

func randomize_colors() -> void:
	var seed_colors: PackedColorArray = _generate_new_colorscheme(3 + randi() % 2, randf_range(0.3, 0.6), 0.7)
	var cols: Array = []
	for i: int in 3:
		var new_col: Color = seed_colors[i].darkened(i / 3.0)
		new_col = new_col.lightened((1.0 - (i / 3.0)) * 0.2)

		cols.append(new_col)

	var final_colors: Array = []
	final_colors.append_array(cols)
	final_colors.append(cols[1])
	final_colors.append(cols[2])
	set_colors(final_colors)
