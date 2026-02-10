extends Node

const SceneIdsScript: GDScript = preload("res://scripts/core/scene_ids.gd")
const TITLE_TO_LEVEL_FADE_SECONDS: float = 3.0

var _scene_root: Node
var _current_scene: Node
var _is_switching: bool = false

func start(scene_root: Node) -> void:
	_scene_root = scene_root
	_go_to_title()

func _go_to_title() -> void:
	_replace_scene(SceneIdsScript.TITLE_SCREEN)
	if _current_scene and _current_scene.has_signal("start_pressed"):
		_current_scene.connect("start_pressed", _on_title_start_pressed, CONNECT_ONE_SHOT)

func _on_title_start_pressed() -> void:
	if _is_switching:
		return

	_is_switching = true
	var do_scene_switch: Callable = func() -> void:
		_replace_scene(SceneIdsScript.LEVEL_1)
	await TransitionManager.transition(do_scene_switch, TITLE_TO_LEVEL_FADE_SECONDS, TITLE_TO_LEVEL_FADE_SECONDS)
	_is_switching = false

func _replace_scene(scene_resource: PackedScene) -> void:
	if _current_scene and is_instance_valid(_current_scene):
		_current_scene.queue_free()

	if scene_resource == null:
		push_error("Failed to load scene resource.")
		return

	_current_scene = scene_resource.instantiate()
	_scene_root.add_child(_current_scene)
