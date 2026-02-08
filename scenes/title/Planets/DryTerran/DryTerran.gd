@tool
extends "res://scenes/title/Planets/Planet.gd"


func set_pixels(amount: float) -> void:
	$Land.material.set_shader_parameter("pixels", amount)
	$Land.offset_left = -amount / 2.0
	$Land.offset_top = -amount / 2.0
	$Land.offset_right = amount / 2.0
	$Land.offset_bottom = amount / 2.0
func set_light(pos: Vector2) -> void:
	$Land.material.set_shader_parameter("light_origin", pos)
func set_seed(sd: float) -> void:
	var converted_seed: float = fmod(sd, 1000.0)/100.0
	$Land.material.set_shader_parameter("seed", converted_seed)
func set_rotates(r: float) -> void:
	$Land.material.set_shader_parameter("rotation", r)
func update_time(t: float) -> void:
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material as ShaderMaterial) * 0.02)
func set_custom_time(t: float) -> void:
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material as ShaderMaterial))

func set_dither(d: bool) -> void:
	$Land.material.set_shader_parameter("should_dither", d)

func get_dither() -> Variant:
	return $Land.material.get_shader_parameter("should_dither")

func get_colors() -> PackedColorArray:
	return get_colors_from_shader($Land.material)

func set_colors(colors: Array) -> void:
	set_colors_on_shader($Land.material, colors)

func randomize_colors() -> void:
	var seed_colors: PackedColorArray = _generate_new_colorscheme(5 + randi() % 3, randf_range(0.3, 0.65), 1.0)
	var cols: Array = []
	for i: int in 5:
		var new_col: Color = seed_colors[i].darkened(i/5.0)
		new_col = new_col.lightened((1.0 - (i/5.0)) * 0.2)

		cols.append(new_col)

	set_colors(cols)
