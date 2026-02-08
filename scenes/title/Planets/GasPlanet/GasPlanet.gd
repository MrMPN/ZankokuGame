extends "res://scenes/title/Planets/Planet.gd"

func set_pixels(amount: float) -> void:
	$Cloud.material.set_shader_parameter("pixels", amount)
	$Cloud2.material.set_shader_parameter("pixels", amount)
	for child: ColorRect in [$Cloud, $Cloud2]:
		child.offset_left = -amount / 2.0
		child.offset_top = -amount / 2.0
		child.offset_right = amount / 2.0
		child.offset_bottom = amount / 2.0

func set_light(pos: Vector2) -> void:
	$Cloud.material.set_shader_parameter("light_origin", pos)
	$Cloud2.material.set_shader_parameter("light_origin", pos)

func set_seed(sd: float) -> void:
	var converted_seed: float = fmod(sd, 1000.0)/100.0
	$Cloud.material.set_shader_parameter("seed", converted_seed)
	$Cloud2.material.set_shader_parameter("seed", converted_seed)
	$Cloud2.material.set_shader_parameter("cloud_cover", randf_range(0.28, 0.5))

func set_rotates(r: float) -> void:
	$Cloud.material.set_shader_parameter("rotation", r)
	$Cloud2.material.set_shader_parameter("rotation", r)
	
func update_time(t: float) -> void:
	$Cloud.material.set_shader_parameter("time", t * get_multiplier($Cloud.material as ShaderMaterial) * 0.005)
	$Cloud2.material.set_shader_parameter("time", t * get_multiplier($Cloud2.material as ShaderMaterial) * 0.005)
	
func set_custom_time(t: float) -> void:
	$Cloud.material.set_shader_parameter("time", t * get_multiplier($Cloud.material as ShaderMaterial))
	$Cloud2.material.set_shader_parameter("time", t * get_multiplier($Cloud2.material as ShaderMaterial))

func get_colors() -> PackedColorArray:
	return get_colors_from_shader($Cloud.material) + get_colors_from_shader($Cloud2.material)

func set_colors(colors: Array) -> void:
	set_colors_on_shader($Cloud.material, colors.slice(0, 4))
	set_colors_on_shader($Cloud2.material, colors.slice(4, 8))

func randomize_colors() -> void:
	var seed_colors: PackedColorArray = _generate_new_colorscheme(8 + randi() % 4, randf_range(0.3, 0.8), 1.0)
	var cols1: Array = []
	var cols2: Array = []
	for i: int in 4:
		var new_col: Color = seed_colors[i].darkened(i / 6.0).darkened(0.7)
#		new_col = new_col.lightened((1.0 - (i/4.0)) * 0.2)
		cols1.append(new_col)
	
	for i: int in 4:
		var new_col: Color = seed_colors[i + 4].darkened(i / 4.0)
		new_col = new_col.lightened((1.0 - (i / 4.0)) * 0.5)
		cols2.append(new_col)

	var final_colors: Array = []
	final_colors.append_array(cols1)
	final_colors.append_array(cols2)
	set_colors(final_colors)
