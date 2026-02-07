extends Node2D

signal start_pressed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		start_pressed.emit()
