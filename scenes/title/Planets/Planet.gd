@tool 
extends Node2D

var time: float = 1000.0
var override_time: bool = false
var original_colors: PackedColorArray
@export var relative_scale : float = 1.0
@export var gui_zoom : float = 1.0

@export var pixels: float = 100.0:
	set(value):
		pixels = value
		if is_node_ready():
			set_pixels(value)

func _ready() -> void:
	original_colors = get_colors()
	set_pixels(pixels)

func set_pixels(_amount: float) -> void:
	pass
func set_light(_pos: Vector2) -> void:
	pass
func set_seed(_sd: float) -> void:
	pass
func set_rotates(_r: float) -> void:
	pass
func update_time(_t: float) -> void:
	pass
func set_custom_time(_t: float) -> void:
	pass

func get_multiplier(mat: ShaderMaterial) -> float:
	return (round(mat.get_shader_parameter("size")) * 2.0) / mat.get_shader_parameter("time_speed")
	
func _process(delta: float) -> void:
	time += delta	
	if !override_time:
		update_time(time)

func set_dither(_d: bool) -> void:
	pass

func get_dither() -> Variant:
	return null

func get_colors() -> PackedColorArray:
	return PackedColorArray()

func get_colors_from_shader(mat: ShaderMaterial, uniform_name: String = "colors") -> PackedColorArray:
	return mat.get_shader_parameter(uniform_name)

func set_colors_on_shader(mat: ShaderMaterial, colors: Array, uniform_name: String = "colors") -> void:
	mat.set_shader_parameter(uniform_name, colors)

func randomize_colors() -> void:
	pass

# Using ideas from https://www.iquilezles.org/www/articles/palettes/palettes.htm
func _generate_new_colorscheme(n_colors: int, hue_diff: float = 0.9, saturation: float = 0.5) -> PackedColorArray:
#	var a = Vector3(rand_range(0.0, 0.5), rand_range(0.0, 0.5), rand_range(0.0, 0.5))
	var a: Vector3 = Vector3(0.5,0.5,0.5)
#	var b: Vector3  = Vector3(rand_range(0.1, 0.6), rand_range(0.1, 0.6), rand_range(0.1, 0.6))
	var b: Vector3  = Vector3(0.5,0.5,0.5) * saturation
	var c: Vector3  = Vector3(randf_range(0.5, 1.5), randf_range(0.5, 1.5), randf_range(0.5, 1.5)) * hue_diff
	var d: Vector3  = Vector3(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0)) * randf_range(1.0, 3.0)

	var cols: PackedColorArray = PackedColorArray()
	var n: float = float(n_colors - 1.0)
	n = max(1, n)
	for i in range(0, n_colors, 1):
		var vec3: Vector3  = Vector3()
		vec3.x = (a.x + b.x *cos(6.28318 * (c.x*float(i/n) + d.x)))
		vec3.y = (a.y + b.y *cos(6.28318 * (c.y*float(i/n) + d.y)))
		vec3.z = (a.z + b.z *cos(6.28318 * (c.z*float(i/n) + d.z)))

		cols.append(Color(vec3.x, vec3.y, vec3.z))
	
	return cols

func get_layers() -> Array:
	var layers: Array = []
	for c in get_children():
		layers.append({"name": c.get_name(), "visible": c.visible})
	return layers

func toggle_layer(num: int) -> void:
	get_children()[num].visible = !get_children()[num].visible
