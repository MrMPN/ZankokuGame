@tool
extends Control

@onready var background: ColorRect = $CanvasLayer/Background
@onready var starstuff: ColorRect = $StarStuff
@onready var nebulae: ColorRect = $Nebulae
@onready var particles: GPUParticles2D = $StarParticles
@onready var starcontainer: Node2D = $StarContainer
@onready var planetcontainer: Node2D = $PlanetContainer

@onready var planet_scene: PackedScene = preload("res://scenes/title/Planets/Rivers/Rivers.tscn") 
@onready var big_star_scene: PackedScene = preload("res://scenes/title/BackgroundGenerator/BigStar.tscn")

var should_tile: bool = false
var reduce_background: bool = false
var mirror_size: Vector2 = Vector2(200.0, 200.0)

@export var colorscheme: GradientTexture2D

var current_palette_colors: PackedColorArray = PackedColorArray()

@export_enum(
	"NYX8", "AMMO-8", "winter wonderland", "borkfest", 
	"submerged chimera", "DREAMSCAPE8", "coffee", 
	"FUNKYFUTURE8", "POLLEN8", "Rust gold 8", 
	"SLSO8", "Goosebumps gold", "OIL6"
) var select_palette: String = "NYX8":
	set(value):
		select_palette = value
		if is_node_ready(): apply_palette(value)

@export var generate_random_colors: bool = false:
	set(value):
		if value:
			randomize_colors()
			generate_random_colors = false

@export_range(0.1, 10.0) var glitter_speed: float = 2.0:
	set(value):
		glitter_speed = value
		if is_node_ready(): generate_new()

@export_range(0.0, 1.0) var glitter_intensity: float = 0.3:
	set(value):
		glitter_intensity = value
		if is_node_ready(): generate_new()

@export var pick_random_seed: bool = false:
	set(value):
		if value:
			current_seed = randi() 
			pick_random_seed = false

# --- FIXED SETTER LOGIC ---
@export var current_seed: int = 0:
	set(value):
		current_seed = value
		# Direct call to generate logic, NO recursion to set_seed
		if is_node_ready():
			generate_new()

var planet_objects: Array[Node2D] = []
var star_objects: Array[Node2D] = []

func _ready() -> void:
	if not starcontainer or not particles: return
	starcontainer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	particles.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not resized.is_connected(_on_resized):
		resized.connect(_on_resized)
	
	if current_palette_colors.is_empty():
		apply_palette(select_palette)

	if current_seed == 0:
		current_seed = randi() # Assigning this triggers the setter -> generate_new
	else:
		# If it was saved in the scene, just generate
		generate_new()

func _on_resized() -> void:
	generate_new()

# --- FIXED HELPER ---
func set_seed(val: int) -> void:
	# Just set the variable. The setter (above) handles the rest.
	current_seed = val

# --- HELPER FUNCTION ---
func _generate_new_colorscheme(n_colors: int, hue_diff: float = 0.9, saturation: float = 0.5) -> PackedColorArray:
	var a: Vector3 = Vector3(0.5, 0.5, 0.5)
	var b: Vector3 = Vector3(0.5, 0.5, 0.5) * saturation
	var c: Vector3 = Vector3(randf_range(0.5, 1.5), randf_range(0.5, 1.5), randf_range(0.5, 1.5)) * hue_diff
	var d: Vector3 = Vector3(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0)) * randf_range(1.0, 3.0)

	var cols: PackedColorArray = PackedColorArray()
	var n: float = float(n_colors - 1.0)
	n = max(1.0, n)
	for i: int in range(0, n_colors, 1):
		var vec3: Vector3 = Vector3()
		vec3.x = (a.x + b.x * cos(6.28318 * (c.x * float(i) / n + d.x)))
		vec3.y = (a.y + b.y * cos(6.28318 * (c.y * float(i) / n + d.y)))
		vec3.z = (a.z + b.z * cos(6.28318 * (c.z * float(i) / n + d.z)))
		cols.append(Color(vec3.x, vec3.y, vec3.z))
	return cols

func apply_palette(name: String) -> void:
	var all_palettes: Dictionary = ColorPalettes.get_palettes()
	if not all_palettes.has(name): return
	current_palette_colors = (all_palettes[name] as PackedColorArray).duplicate()
	set_colors(current_palette_colors)

func set_colors(colors: PackedColorArray) -> void:
	current_palette_colors = colors.duplicate()
	if colors.size() < 2: return
	
	# 1. Background Color
	var bg: Color = colors[0]
	set_background_color(bg)
	
	# 2. Gradient Colors
	var gradient_cols: PackedColorArray = colors.slice(1)
	
	# --- FIX: FORCE GRADIENT SETTINGS ---
	# Ensure the gradient is strictly horizontal (0,0 -> 1,0)
	colorscheme.fill_from = Vector2(0, 0)
	colorscheme.fill_to = Vector2(1, 0)
	colorscheme.fill = GradientTexture2D.FILL_LINEAR
	
	# Set width exactly to the number of colors so each pixel is one color
	colorscheme.width = int(max(float(gradient_cols.size()), 1.0))
	colorscheme.height = 1
	
	# Force "Constant" interpolation (Hard edges, no blurring)
	if colorscheme.gradient == null: colorscheme.gradient = Gradient.new()
	colorscheme.gradient.colors = gradient_cols
	colorscheme.gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	# ------------------------------------
	
	# 3. Update Shaders
	# Pass the "color count" to the shader so it maps values correctly
	var count: float = float(gradient_cols.size())
	
	_set_new_colors(colorscheme, bg)
	
	# Update these manually to ensure the new count is passed
	(starstuff.material as ShaderMaterial).set_shader_parameter(&"color_count", count)
	(nebulae.material as ShaderMaterial).set_shader_parameter(&"color_count", count)
	
	generate_new()

func randomize_colors() -> void:
	current_palette_colors = _generate_new_colorscheme(5, randf_range(0.5, 1.2), randf_range(0.3, 0.8))
	set_colors(current_palette_colors)

func generate_new() -> void:
	if not is_node_ready() or not starstuff or not particles: return

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = current_seed
	
	var starstuff_mat: ShaderMaterial = starstuff.material as ShaderMaterial
	starstuff_mat.set_shader_parameter(&"seed", rng.randf_range(1.0, 10.0))
	starstuff_mat.set_shader_parameter(&"pixels", max(size.x, size.y)) 
	starstuff_mat.set_shader_parameter(&"anim_speed", glitter_speed)
	starstuff_mat.set_shader_parameter(&"glitter_strength", glitter_intensity)
	
	var aspect: Vector2 = Vector2(1.0, 1.0)
	if size.x > size.y: aspect = Vector2(size.x / size.y, 1.0)
	else: aspect = Vector2(1.0, size.y / size.x)
	starstuff_mat.set_shader_parameter(&"uv_correct", aspect)
	
	var nebulae_mat: ShaderMaterial = nebulae.material as ShaderMaterial
	nebulae_mat.set_shader_parameter(&"seed", rng.randf_range(1.0, 10.0) + 123.45)
	nebulae_mat.set_shader_parameter(&"pixels", max(size.x, size.y))
	nebulae_mat.set_shader_parameter(&"uv_correct", aspect)
	nebulae_mat.set_shader_parameter(&"glitter_strength", 0.0)
	
	particles.speed_scale = 1.0
	particles.amount = 1 
	particles.position = Vector2.ZERO
	
	if particles.process_material is ShaderMaterial:
		var part_mat: ShaderMaterial = particles.process_material as ShaderMaterial
		part_mat.set_shader_parameter(&"screen_size", size)
		part_mat.set_shader_parameter(&"colorscheme", colorscheme)
		part_mat.set_shader_parameter(&"anim_speed", glitter_speed)
		part_mat.set_shader_parameter(&"glitter_strength", glitter_intensity)
	
	var p_amount: float = (size.x * size.y) / 150.0
	particles.amount = int(rng.randf() * (p_amount * 0.75)) + int(p_amount * 0.25)
	particles.seed = current_seed
	particles.restart()
	
	_make_new_planets(rng)
	_make_new_stars(rng)

func _make_new_stars(rng: RandomNumberGenerator) -> void:
	for s: Node2D in star_objects:
		if is_instance_valid(s): s.queue_free()
	star_objects = []
	var star_amount: int = int(max(size.x, size.y) / 20.0)
	star_amount = max(star_amount, 1)
	for i: int in range(rng.randi() % star_amount):
		_place_big_star(rng)
	
func _make_new_planets(rng: RandomNumberGenerator) -> void:
	# 1. Clean up old planets
	for p: Node2D in planet_objects:
		if is_instance_valid(p): p.queue_free()
	planet_objects = []

	# 2. Always create exactly ONE planet
	_place_planet(rng)

func _place_planet(rng: RandomNumberGenerator) -> void:
	var min_size: float = min(size.x, size.y)
	var scale_val: Vector2 = Vector2(1, 1) * (rng.randf_range(0.2, 0.7) * rng.randf_range(0.5, 1.0) * min_size * 0.005)
	var pos: Vector2 = Vector2()
	if should_tile:
		var offs: float = scale_val.x * 100.0 * 0.5
		pos = Vector2(int(rng.randf_range(offs, size.x - offs)), int(rng.randf_range(offs, size.y - offs)))
	else:
		pos = Vector2(int(rng.randf_range(0.0, size.x)), int(rng.randf_range(0.0, size.y)))
	
	var planet: Node2D = planet_scene.instantiate() as Node2D
	planet.scale = scale_val
	planet.position = pos
	
	print("\n--- SPAWNING PLANET ---")
	
	# --- COLOR LOGIC ---
	if not current_palette_colors.is_empty() and current_palette_colors.size() > 1:
		var valid_colors: PackedColorArray = current_palette_colors.slice(1)
		print("BG_GEN: Palette has ", valid_colors.size(), " valid colors.")
		
		var water_base: Color = valid_colors[rng.randi() % valid_colors.size()]
		var land_base: Color = valid_colors[rng.randi() % valid_colors.size()]
		var cloud_base: Color = valid_colors[rng.randi() % valid_colors.size()]
		
		var planet_cols: PackedColorArray = PackedColorArray()
		
		# 2. WATER (3 Colors)
		for i: int in range(3):
			var t: float = float(i) / 2.0
			planet_cols.append(water_base.darkened(0.6).lerp(water_base.lightened(0.1), t))
			
		# 3. LAND (4 Colors)
		for i: int in range(4):
			var t: float = float(i) / 3.0
			planet_cols.append(land_base.darkened(0.5).lerp(land_base.lightened(0.4), t))
			
		# 4. CLOUD (4 Colors)
		for i: int in range(4):
			var t: float = float(i) / 3.0
			planet_cols.append(cloud_base.darkened(0.1).lerp(Color(0.95, 0.95, 0.95), t))
			
		print("BG_GEN: Generated ", planet_cols.size(), " colors for planet.")
		
		if planet.has_method(&"set_colors"):
			print("BG_GEN: Sending colors to planet instance...")
			planet.call(&"set_colors", planet_cols)
		else:
			print("BG_GEN: ERROR! Planet script is missing 'set_colors' function.")
	else:
		print("BG_GEN: Current Palette is empty or invalid!")

	if planet.has_method(&"set_seed"):
		planet.call(&"set_seed", rng.randf() * 100.0)
	
	planetcontainer.add_child(planet)
	planet_objects.append(planet)
	
func _place_big_star(rng: RandomNumberGenerator) -> void:
	var pos: Vector2 = Vector2(rng.randf_range(0.0, size.x), rng.randf_range(0.0, size.y))
	if should_tile:
		var offs: float = 10.0
		pos = Vector2(rng.randf_range(offs, size.x - offs), rng.randf_range(offs, size.y - offs))

	var star: Node2D = big_star_scene.instantiate() as Node2D
	star.position = pos
	if "custom_speed" in star:
		star.set(&"custom_speed", glitter_speed)
	if "custom_intensity" in star:
		star.set(&"custom_intensity", glitter_intensity)
	if star.has_method(&"set_rng_seed"):
		star.call(&"set_rng_seed", rng.randi())
	starcontainer.add_child(star)
	star_objects.append(star)

func _set_new_colors(new_scheme: GradientTexture2D, new_background: Color) -> void:
	colorscheme = new_scheme
	(starstuff.material as ShaderMaterial).set_shader_parameter(&"colorscheme", colorscheme)
	(nebulae.material as ShaderMaterial).set_shader_parameter(&"colorscheme", colorscheme)
	(nebulae.material as ShaderMaterial).set_shader_parameter(&"background_color", new_background)
	if particles.process_material is ShaderMaterial:
		(particles.process_material as ShaderMaterial).set_shader_parameter(&"colorscheme", colorscheme)
	for p: Node2D in planet_objects:
		if (p as CanvasItem).material: (p as CanvasItem).material.set_shader_parameter(&"colorscheme", colorscheme)
	for s: Node2D in star_objects:
		if (s as CanvasItem).material is ShaderMaterial: (s as CanvasItem).material.set_shader_parameter(&"colorscheme", colorscheme)

func set_background_color(c: Color) -> void:
	background.color = c
	(nebulae.material as ShaderMaterial).set_shader_parameter(&"background_color", c)

func toggle_dust() -> void:
	starstuff.visible = !starstuff.visible
func toggle_stars() -> void:
	starcontainer.visible = !starcontainer.visible
	particles.visible = !particles.visible
func toggle_nebulae() -> void:
	nebulae.visible = !nebulae.visible
func toggle_planets() -> void:
	planetcontainer.visible = !planetcontainer.visible
func toggle_transparancy() -> void:
	background.visible = !background.visible
