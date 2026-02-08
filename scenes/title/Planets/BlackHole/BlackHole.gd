@tool
extends "res://scenes/title/Planets/Planet.gd"



func set_pixels(amount: float) -> void:
	$BlackHole.material.set_shader_parameter("pixels", amount)
	# times 3 here because in this case ring is 3 times larger than planet
	$Disk.material.set_shader_parameter("pixels", amount*3.0)
	
	$BlackHole.offset_left = -amount / 2.0
	$BlackHole.offset_top = -amount / 2.0
	$BlackHole.offset_right = amount / 2.0
	$BlackHole.offset_bottom = amount / 2.0

	$Disk.offset_left = -amount * 3.0 / 2.0
	$Disk.offset_top = -amount * 3.0 / 2.0
	$Disk.offset_right = amount * 3.0 / 2.0
	$Disk.offset_bottom = amount * 3.0 / 2.0

func set_light(_pos: Vector2) -> void:
	pass

func set_seed(sd: float) -> void:
	var converted_seed: float = fmod(sd, 1000.0)/100.0
	$Disk.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r: float) -> void:
	$Disk.material.set_shader_parameter("rotation", r+0.7)

func update_time(t: float) -> void:
	$Disk.material.set_shader_parameter("time", t * 314.15 * 0.004 )

func set_custom_time(t: float) -> void:
	$Disk.material.set_shader_parameter("time", t * 314.15 * $Disk.material.get_shader_parameter("time_speed") * 0.5)

func set_dither(d: bool) -> void:
	$Disk.material.set_shader_parameter("should_dither", d)

func get_dither() -> Variant:
	return $Disk.material.get_shader_parameter("should_dither")

func get_colors() -> PackedColorArray:
	return get_colors_from_shader($BlackHole.material) + get_colors_from_shader($Disk.material)

func set_colors(colors: Array) -> void:
	var cols1: Array = colors.slice(0, 3)
	var cols2: Array = colors.slice(3, 8)
	set_colors_on_shader($BlackHole.material, cols1)
	set_colors_on_shader($Disk.material, cols2)

func randomize_colors() -> void:
	var seed_colors: PackedColorArray = _generate_new_colorscheme(5 + randi() % 2, randf_range(0.3, 0.5), 2.0)
	var cols: Array = []
	for i: int in 5:
		var new_col: Color = seed_colors[i].darkened((i/5.0) * 0.7)
		new_col = new_col.lightened((1.0 - (i/5.0)) * 0.9)

		cols.append(new_col)

	var final_colors: Array = []
	final_colors.append(Color("272736"))
	final_colors.append(cols[0])
	final_colors.append(cols[3])
	final_colors.append_array(cols)
	set_colors(final_colors)
