@tool
extends Control

@onready var background = $CanvasLayer/Background
@onready var starstuff = $StarStuff
@onready var nebulae = $Nebulae
@onready var particles = $StarParticles
@onready var starcontainer = $StarContainer
@onready var planetcontainer = $PlanetContainer

@onready var planet_scene = preload("res://Planets/Rivers/Rivers.tscn") 
@onready var big_star_scene = preload("res://BackgroundGenerator/BigStar.tscn")

var should_tile = false
var reduce_background = false
var mirror_size = Vector2(200, 200)

@export var colorscheme: GradientTexture2D

var current_palette_colors: PackedColorArray = []

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

var planet_objects = []
var star_objects = []

func _ready():
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

func _on_resized():
	generate_new()

# --- FIXED HELPER ---
func set_seed(val):
	# Just set the variable. The setter (above) handles the rest.
	current_seed = val

# --- HELPER FUNCTION ---
func _generate_new_colorscheme(n_colors, hue_diff = 0.9, saturation = 0.5):
	var a = Vector3(0.5,0.5,0.5)
	var b = Vector3(0.5,0.5,0.5) * saturation
	var c = Vector3(randf_range(0.5, 1.5), randf_range(0.5, 1.5), randf_range(0.5, 1.5)) * hue_diff
	var d = Vector3(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0)) * randf_range(1.0, 3.0)

	var cols = PackedColorArray()
	var n = float(n_colors - 1.0)
	n = max(1, n)
	for i in range(0, n_colors, 1):
		var vec3 = Vector3()
		vec3.x = (a.x + b.x * cos(6.28318 * (c.x*float(i)/n + d.x)))
		vec3.y = (a.y + b.y * cos(6.28318 * (c.y*float(i)/n + d.y)))
		vec3.z = (a.z + b.z * cos(6.28318 * (c.z*float(i)/n + d.z)))
		cols.append(Color(vec3.x, vec3.y, vec3.z))
	return cols

func apply_palette(name: String):
	var all_palettes = ColorPalettes.get_palettes()
	if not all_palettes.has(name): return
	current_palette_colors = all_palettes[name].duplicate()
	set_colors(current_palette_colors)

func set_colors(colors: PackedColorArray):
	current_palette_colors = colors.duplicate()
	if colors.size() < 2: return
	
	# 1. Background Color
	var bg = colors[0]
	set_background_color(bg)
	
	# 2. Gradient Colors
	var gradient_cols = colors.slice(1)
	
	# --- FIX: FORCE GRADIENT SETTINGS ---
	# Ensure the gradient is strictly horizontal (0,0 -> 1,0)
	colorscheme.fill_from = Vector2(0, 0)
	colorscheme.fill_to = Vector2(1, 0)
	colorscheme.fill = GradientTexture2D.FILL_LINEAR
	
	# Set width exactly to the number of colors so each pixel is one color
	colorscheme.width = max(gradient_cols.size(), 1)
	colorscheme.height = 1
	
	# Force "Constant" interpolation (Hard edges, no blurring)
	if colorscheme.gradient == null: colorscheme.gradient = Gradient.new()
	colorscheme.gradient.colors = gradient_cols
	colorscheme.gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	# ------------------------------------
	
	# 3. Update Shaders
	# Pass the "color count" to the shader so it maps values correctly
	var count = float(gradient_cols.size())
	
	_set_new_colors(colorscheme, bg)
	
	# Update these manually to ensure the new count is passed
	starstuff.material.set_shader_parameter("color_count", count)
	nebulae.material.set_shader_parameter("color_count", count)
	
	generate_new()

func randomize_colors():
	current_palette_colors = _generate_new_colorscheme(5, randf_range(0.5, 1.2), randf_range(0.3, 0.8))
	set_colors(current_palette_colors)

func generate_new():
	if not is_node_ready() or not starstuff or not particles: return

	var rng = RandomNumberGenerator.new()
	rng.seed = current_seed
	
	starstuff.material.set_shader_parameter("seed", rng.randf_range(1.0, 10.0))
	starstuff.material.set_shader_parameter("pixels", max(size.x, size.y)) 
	starstuff.material.set_shader_parameter("anim_speed", glitter_speed)
	starstuff.material.set_shader_parameter("glitter_strength", glitter_intensity)
	
	var aspect = Vector2(1, 1)
	if size.x > size.y: aspect = Vector2(size.x / size.y, 1.0)
	else: aspect = Vector2(1.0, size.y / size.x)
	starstuff.material.set_shader_parameter("uv_correct", aspect)
	
	nebulae.material.set_shader_parameter("seed", rng.randf_range(1.0, 10.0) + 123.45)
	nebulae.material.set_shader_parameter("pixels", max(size.x, size.y))
	nebulae.material.set_shader_parameter("uv_correct", aspect)
	nebulae.material.set_shader_parameter("glitter_strength", 0.0)
	
	particles.speed_scale = 1.0
	particles.amount = 1 
	particles.position = Vector2.ZERO
	
	if particles.process_material is ShaderMaterial:
		particles.process_material.set_shader_parameter("screen_size", size)
		particles.process_material.set_shader_parameter("colorscheme", colorscheme)
		particles.process_material.set_shader_parameter("anim_speed", glitter_speed)
		particles.process_material.set_shader_parameter("glitter_strength", glitter_intensity)
	
	var p_amount = (size.x * size.y) / 150
	particles.amount = int(rng.randf() * (p_amount * 0.75)) + int(p_amount * 0.25)
	particles.seed = current_seed
	particles.restart()
	
	_make_new_planets(rng)
	_make_new_stars(rng)

func _make_new_stars(rng: RandomNumberGenerator):
	for s in star_objects:
		if is_instance_valid(s): s.queue_free()
	star_objects = []
	var star_amount = int(max(size.x, size.y) / 20)
	star_amount = max(star_amount, 1)
	for i in range(rng.randi() % star_amount):
		_place_big_star(rng)
	
func _make_new_planets(rng: RandomNumberGenerator):
	# 1. Clean up old planets
	for p in planet_objects:
		if is_instance_valid(p): p.queue_free()
	planet_objects = []

	# 2. Always create exactly ONE planet
	_place_planet(rng)

func _place_planet(rng: RandomNumberGenerator):
	var min_size = min(size.x, size.y)
	var scale_val = Vector2(1, 1) * (rng.randf_range(0.2, 0.7) * rng.randf_range(0.5, 1.0) * min_size * 0.005)
	var pos = Vector2()
	if should_tile:
		var offs = scale_val.x * 100.0 * 0.5
		pos = Vector2(int(rng.randf_range(offs, size.x - offs)), int(rng.randf_range(offs, size.y - offs)))
	else:
		pos = Vector2(int(rng.randf_range(0, size.x)), int(rng.randf_range(0, size.y)))
	
	var planet = planet_scene.instantiate()
	planet.scale = scale_val
	planet.position = pos
	
	print("\n--- SPAWNING PLANET ---")
	
	# --- COLOR LOGIC ---
	if not current_palette_colors.is_empty() and current_palette_colors.size() > 1:
		var valid_colors = current_palette_colors.slice(1)
		print("BG_GEN: Palette has ", valid_colors.size(), " valid colors.")
		
		var water_base = valid_colors[rng.randi() % valid_colors.size()]
		var land_base = valid_colors[rng.randi() % valid_colors.size()]
		var cloud_base = valid_colors[rng.randi() % valid_colors.size()]
		
		var planet_cols = PackedColorArray()
		
		# 2. WATER (3 Colors)
		for i in range(3):
			var t = float(i) / 2.0
			planet_cols.append(water_base.darkened(0.6).lerp(water_base.lightened(0.1), t))
			
		# 3. LAND (4 Colors)
		for i in range(4):
			var t = float(i) / 3.0
			planet_cols.append(land_base.darkened(0.5).lerp(land_base.lightened(0.4), t))
			
		# 4. CLOUD (4 Colors)
		for i in range(4):
			var t = float(i) / 3.0
			planet_cols.append(cloud_base.darkened(0.1).lerp(Color(0.95, 0.95, 0.95), t))
			
		print("BG_GEN: Generated ", planet_cols.size(), " colors for planet.")
		
		if planet.has_method("set_colors"):
			print("BG_GEN: Sending colors to planet instance...")
			planet.set_colors(planet_cols)
		else:
			print("BG_GEN: ERROR! Planet script is missing 'set_colors' function.")
	else:
		print("BG_GEN: Current Palette is empty or invalid!")

	if planet.has_method("set_seed"):
		planet.set_seed(rng.randf() * 100.0)
	
	planetcontainer.add_child(planet)
	planet_objects.append(planet)

func _place_big_star(rng: RandomNumberGenerator):
	var pos = Vector2()
	if should_tile:
		var offs = 10.0
		pos = Vector2(int(rng.randf_range(offs, size.x - offs)), int(rng.randf_range(offs, size.y - offs)))
	else:
		pos = Vector2(int(rng.randf_range(0, size.x)), int(rng.randf_range(0, size.y)))
	var star = big_star_scene.instantiate()
	star.position = pos
	star.custom_speed = glitter_speed
	star.custom_intensity = glitter_intensity
	if star.has_method("set_rng_seed"):
		star.set_rng_seed(rng.randi())
	starcontainer.add_child(star)
	star_objects.append(star)

func _set_new_colors(new_scheme, new_background):
	colorscheme = new_scheme
	starstuff.material.set_shader_parameter("colorscheme", colorscheme)
	nebulae.material.set_shader_parameter("colorscheme", colorscheme)
	nebulae.material.set_shader_parameter("background_color", new_background)
	if particles.process_material is ShaderMaterial:
		particles.process_material.set_shader_parameter("colorscheme", colorscheme)
	for p in planet_objects:
		if p.material: p.material.set_shader_parameter("colorscheme", colorscheme)
	for s in star_objects:
		if s.material: s.material.set_shader_parameter("colorscheme", colorscheme)

func set_background_color(c):
	background.color = c
	nebulae.material.set_shader_parameter("background_color", c)

func toggle_dust(): starstuff.visible = !starstuff.visible
func toggle_stars(): 
	starcontainer.visible = !starcontainer.visible
	particles.visible = !particles.visible
func toggle_nebulae(): nebulae.visible = !nebulae.visible
func toggle_planets(): planetcontainer.visible = !planetcontainer.visible
func toggle_transparancy(): background.visible = !background.visible
