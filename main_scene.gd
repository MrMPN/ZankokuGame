extends Node2D

func _ready() -> void:
	var title_screen: Node = load("res://scenes/title/title_screen.tscn").instantiate()
	title_screen.connect("start_pressed", _on_title_screen_start_pressed.bind(title_screen))
	add_child(title_screen)

func _on_title_screen_start_pressed(title_screen: Node) -> void:
	title_screen.queue_free()
	var character_scene: Node = load("res://scenes/level1/level_1.tscn").instantiate()
	add_child(character_scene)
 
