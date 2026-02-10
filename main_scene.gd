extends Node2D

const TITLE_SCENE_PATH: String = "res://scenes/title/title_screen.tscn"
const LEVEL_SCENE_PATH: String = "res://scenes/level1/level_1.tscn"

var _is_switching: bool = false

func _ready() -> void:
	var title_screen: Node = load(TITLE_SCENE_PATH).instantiate()
	title_screen.connect("start_pressed", _on_title_screen_start_pressed.bind(title_screen))
	add_child(title_screen)

func _on_title_screen_start_pressed(title_screen: Node) -> void:
	if _is_switching:
		return

	_is_switching = true
	var do_scene_switch: Callable = func() -> void:
		if is_instance_valid(title_screen):
			title_screen.queue_free()
		var level_scene: Node = load(LEVEL_SCENE_PATH).instantiate()
		add_child(level_scene)

	await TransitionManager.transition(do_scene_switch, 3.0, 3.0)
	_is_switching = false
