extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MainCharacter2/AudioStreamPlayer2D.play()
	$MainCharacter2/AudioStreamPlayer2D2.play()

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
