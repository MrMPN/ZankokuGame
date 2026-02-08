@tool
extends "res://scenes/title/Planets/Planet.gd"

func set_pixels(amount: float) -> void:
	$Blobs.material.set_shader_parameter("pixels", amount*relative_scale)
	$Star.material.set_shader_parameter("pixels", amount)
	$StarFlares.material.set_shader_parameter("pixels", amount*relative_scale)

	$Star.offset_left = -amount / 2.0
	$Star.offset_top = -amount / 2.0
	$Star.offset_right = amount / 2.0
	$Star.offset_bottom = amount / 2.0

	for child: ColorRect in [$StarFlares, $Blobs]:
		child.offset_left = -amount * relative_scale / 2.0
		child.offset_top = -amount * relative_scale / 2.0
		child.offset_right = amount * relative_scale / 2.0
		child.offset_bottom = amount * relative_scale / 2.0

func set_light(_pos: Vector2) -> void:
	pass

func set_seed(sd: float) -> void:
	var converted_seed: float = fmod(sd, 1000.0)/100.0
	$Blobs.material.set_shader_parameter("seed", converted_seed)
	$Star.material.set_shader_parameter("seed", converted_seed)
	$StarFlares.material.set_shader_parameter("seed", converted_seed)

var starcolor1: Gradient = Gradient.new()
var starcolor2: Gradient = Gradient.new()
var starflarecolor1: Gradient = Gradient.new()
var starflarecolor2: Gradient = Gradient.new()

func _ready() -> void:
	starcolor1.offsets = [0.0, 0.33, 0.66, 1.0] as PackedFloat32Array
	starcolor2.offsets = [0.0, 0.33, 0.66, 1.0] as PackedFloat32Array
	starflarecolor1.offsets = [0.0, 1.0] as PackedFloat32Array
	starflarecolor2.offsets = [0.0, 1.0] as PackedFloat32Array
	
	starcolor1.colors = [Color("f5ffe8"), Color("ffd832"), Color("ff823b"), Color("7c191a")] as PackedColorArray
	starcolor2.colors = [Color("f5ffe8"), Color("77d6c1"), Color("1c92a7"), Color("033e5e")] as PackedColorArray
	
	starflarecolor1.colors = [Color("ffd832"), Color("f5ffe8")] as PackedColorArray
	starflarecolor2.colors = [Color("77d6c1"), Color("f5ffe8")] as PackedColorArray

func _set_colors(sd: int) -> void:
	if (sd % 2 == 0):
		$Star.material.get_shader_parameter("colorramp").gradient = starcolor1
		$StarFlares.material.get_shader_parameter("colorramp").gradient = starflarecolor1
	else:
		$Star.material.get_shader_parameter("colorramp").gradient = starcolor2
		$StarFlares.material.get_shader_parameter("colorramp").gradient = starflarecolor2

func set_rotates(r: float) -> void:
	$Blobs.material.set_shader_parameter("rotation", r)
	$Star.material.set_shader_parameter("rotation", r)
	$StarFlares.material.set_shader_parameter("rotation", r)

func update_time(t: float) -> void:
	$Blobs.material.set_shader_parameter("time", t * get_multiplier($Blobs.material as ShaderMaterial) * 0.01)
	$Star.material.set_shader_parameter("time", t * get_multiplier($Star.material as ShaderMaterial) * 0.005)
	$StarFlares.material.set_shader_parameter("time", t * get_multiplier($StarFlares.material as ShaderMaterial) * 0.015)

func set_custom_time(t: float) -> void:
	$Blobs.material.set_shader_parameter("time", t * get_multiplier($Blobs.material as ShaderMaterial))
	$Star.material.set_shader_parameter("time", t * (1.0 / ($Star.material as ShaderMaterial).get_shader_parameter(&"time_speed")))
	$StarFlares.material.set_shader_parameter("time", t * get_multiplier($StarFlares.material as ShaderMaterial))

func set_dither(d: bool) -> void:
	$Star.material.set_shader_parameter("should_dither", d)
	$StarFlares.material.set_shader_parameter("should_dither", d)

func get_dither() -> Variant:
	return $Star.material.get_shader_parameter("should_dither")

func get_colors() -> PackedColorArray:
	return get_colors_from_shader($Blobs.material) + get_colors_from_shader($Star.material) + get_colors_from_shader($StarFlares.material)

func set_colors(colors: Array) -> void:
	set_colors_on_shader($Blobs.material, colors.slice(0, 1))
	set_colors_on_shader($Star.material, colors.slice(1, 6))
	set_colors_on_shader($StarFlares.material, colors.slice(6, 10))


func randomize_colors() -> void:
	var seed_colors: PackedColorArray = _generate_new_colorscheme(4, randf_range(0.2, 0.4), 2.0)
	var cols: Array = []
	for i: int in 4:
		var new_col: Color = seed_colors[i].darkened((i / 4.0) * 0.9)
		new_col = new_col.lightened((1.0 - (i / 4.0)) * 0.8)

		cols.append(new_col)
	cols[0] = cols[0].lightened(0.8)

	var final_colors: Array = []
	final_colors.append(cols[0])
	final_colors.append_array(cols)
	final_colors.append(cols[1])
	final_colors.append(cols[0])
	set_colors(final_colors)
