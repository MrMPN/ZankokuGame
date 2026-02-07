extends Node2D

func _ready():
	var title_screen = load("res://scenes/title/title_screen.tscn").instantiate()
	add_child(title_screen)
