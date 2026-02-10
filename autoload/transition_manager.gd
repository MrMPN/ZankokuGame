extends Node

var _layer: CanvasLayer
var _fade_rect: ColorRect
var _is_transitioning: bool = false
var _is_initialized: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_initialize_overlay")

func _initialize_overlay() -> void:
	if _is_initialized:
		return

	_layer = CanvasLayer.new()
	_layer.layer = 100
	get_tree().root.add_child(_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.offset_left = 0.0
	_fade_rect.offset_top = 0.0
	_fade_rect.offset_right = 0.0
	_fade_rect.offset_bottom = 0.0
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_fade_rect)
	_is_initialized = true

func fade_out(duration: float = 0.35) -> void:
	await _ensure_initialized()
	await _tween_alpha_to(1.0, duration)

func fade_in(duration: float = 0.35) -> void:
	await _ensure_initialized()
	await _tween_alpha_to(0.0, duration)

func transition(action: Callable, fade_out_duration: float = 0.35, fade_in_duration: float = 0.35) -> void:
	await _ensure_initialized()

	if _is_transitioning:
		return

	_is_transitioning = true
	await fade_out(fade_out_duration)
	action.call()
	await fade_in(fade_in_duration)
	_is_transitioning = false

func _ensure_initialized() -> void:
	while not _is_initialized:
		await get_tree().process_frame

func _tween_alpha_to(alpha: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "color:a", clampf(alpha, 0.0, 1.0), maxf(duration, 0.0))
	await tween.finished
