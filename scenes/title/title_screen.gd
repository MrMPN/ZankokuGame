extends Node2D

signal start_pressed
signal start_requested

@onready var spaceship: Node2D = $Spaceship
@onready var start_label: RichTextLabel = $CanvasLayer/Start

var _is_starting: bool = false

func _ready() -> void:
	start_requested.connect(Callable(spaceship, "start_flight"))
	spaceship.connect("flight_finished", _on_spaceship_flight_finished)

func _input(event: InputEvent) -> void:
	if _is_starting:
		return

	if event.is_action_pressed("ui_accept"):
		_is_starting = true
		start_label.hide()
		start_requested.emit()

func _on_spaceship_flight_finished() -> void:
	start_pressed.emit()
