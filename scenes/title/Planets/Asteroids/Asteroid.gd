@tool
extends "res://scenes/title/Planets/Planet.gd"

func set_pixels(amount: float) -> void:
	$Asteroid.material.set_shader_parameter("pixels", amount)

func set_light(pos: Vector2) -> void:
	$Asteroid.material.set_shader_parameter("light_origin", pos)

func set_seed(sd: float) -> void:
	var converted_seed: float = fmod(sd, 1000.0)/100.0
	$Asteroid.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r: float) -> void:
	$Asteroid.material.set_shader_parameter("rotation", r)

func update_time(_t: float) -> void:
	pass

func set_custom_time(t: float) -> void:
	$Asteroid.material.set_shader_parameter("rotation", t * PI * 2.0)

func set_dither(d: bool) -> void:
	$Asteroid.material.set_shader_parameter("should_dither", d)

func get_dither() -> Variant:
	return $Asteroid.material.get_shader_parameter("should_dither")

func get_colors() -> PackedColorArray:
	return get_colors_from_shader($Asteroid.material)

func set_colors(colors: Array) -> void:
	set_colors_on_shader($Asteroid.material, colors)

func randomize_colors() -> void:
	var seed_colors: PackedColorArray = _generate_new_colorscheme(3 + randi()%2, randf_range(0.3, 0.6), 0.7)
	var cols: Array = []
	for i: int in 3:
		var new_col: Color = seed_colors[i].darkened(i/3.0)
		new_col = new_col.lightened((1.0 - (i/3.0)) * 0.2)

		cols.append(new_col)

	set_colors(cols)
