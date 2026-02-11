extends Node2D

signal start_pressed
signal start_requested

@onready var spaceship: Node2D = $Spaceship
@onready var start_label: RichTextLabel = $CanvasLayer/Start
@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var intro_sound_player: AudioStreamPlayer = $IntroSoundPlayer

var _is_starting: bool = false
var _music_fade_tween: Tween = null
var _intro_fade_tween: Tween = null
var _manual_advance_backup: bool = true
var _manual_advance_locked: bool = false

@export var music_fade_duration: float = 3.0
@export var intro_sound_fade_in_delay: float = 5.0
@export var dialog_start_delay: float = 10.0
@export var dialog_timeline_path: String = "res://dialogs/timeline.dtl"
@export var auto_advance_only_for_intro: bool = true

func _ready() -> void:
	start_requested.connect(Callable(spaceship, "start_flight"))
	spaceship.connect("flight_finished", _on_spaceship_flight_finished)
	intro_sound_player.finished.connect(_on_intro_sound_finished)

func _exit_tree() -> void:
	if Dialogic and Dialogic.timeline_ended.is_connected(_on_dialogic_timeline_ended):
		Dialogic.timeline_ended.disconnect(_on_dialogic_timeline_ended)
	_unlock_dialogic_manual_advance()

func _input(event: InputEvent) -> void:
	if _is_starting:
		return

	if _is_start_action(event):
		_is_starting = true
		start_label.hide()
		start_requested.emit()
		_start_intro_sequence()

func _is_start_action(event: InputEvent) -> bool:
	var is_ui_start := InputMap.has_action("ui_start") and event.is_action_pressed("ui_start")
	var is_ui_accept := event.is_action_pressed("ui_accept")
	return is_ui_start or is_ui_accept

func _start_intro_sequence() -> void:
	_crossfade_music_to_intro_sound(music_fade_duration)
	await get_tree().create_timer(max(dialog_start_delay, 0.0)).timeout
	if auto_advance_only_for_intro:
		_lock_dialogic_manual_advance()
	Dialogic.Inputs.auto_advance.enabled_forced = true
	Dialogic.start(dialog_timeline_path)

	if auto_advance_only_for_intro and not Dialogic.timeline_ended.is_connected(_on_dialogic_timeline_ended):
		Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)

func _crossfade_music_to_intro_sound(duration: float) -> void:
	if is_instance_valid(_music_fade_tween):
		_music_fade_tween.kill()
	if is_instance_valid(_intro_fade_tween):
		_intro_fade_tween.kill()

	if is_instance_valid(intro_sound_player):
		intro_sound_player.volume_db = -80.0
		if intro_sound_player.playing:
			intro_sound_player.stop()

	if duration <= 0.0:
		if is_instance_valid(music_player) and music_player.playing:
			music_player.stop()
			music_player.volume_db = 0.0
		if is_instance_valid(intro_sound_player):
			intro_sound_player.play()
			intro_sound_player.volume_db = 0.0
		return

	_music_fade_tween = create_tween()
	if is_instance_valid(music_player) and music_player.playing:
		_music_fade_tween.parallel().tween_property(music_player, "volume_db", -80.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	_music_fade_tween.finished.connect(func() -> void:
		if is_instance_valid(music_player) and music_player.playing:
			music_player.stop()
			music_player.volume_db = 0.0
	)

	if not is_instance_valid(intro_sound_player):
		return

	var fade_in_delay: float = max(0.0, intro_sound_fade_in_delay)
	var fade_in_duration: float = max(0.05, duration - min(fade_in_delay, duration))
	if fade_in_delay <= 0.0:
		intro_sound_player.play()
		_intro_fade_tween = create_tween()
		_intro_fade_tween.tween_property(intro_sound_player, "volume_db", 0.0, fade_in_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		return

	var timer: SceneTreeTimer = get_tree().create_timer(fade_in_delay)
	timer.timeout.connect(func() -> void:
		if not _is_starting or not is_instance_valid(intro_sound_player):
			return
		intro_sound_player.play()
		_intro_fade_tween = create_tween()
		_intro_fade_tween.tween_property(intro_sound_player, "volume_db", 0.0, fade_in_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	)

func _on_spaceship_flight_finished() -> void:
	start_pressed.emit()

func _lock_dialogic_manual_advance() -> void:
	if _manual_advance_locked:
		return
	_manual_advance_backup = Dialogic.Inputs.manual_advance.system_enabled
	Dialogic.Inputs.manual_advance.system_enabled = false
	_manual_advance_locked = true

func _unlock_dialogic_manual_advance() -> void:
	if not _manual_advance_locked:
		return
	Dialogic.Inputs.manual_advance.system_enabled = _manual_advance_backup
	_manual_advance_locked = false

func _on_dialogic_timeline_ended() -> void:
	if Dialogic.timeline_ended.is_connected(_on_dialogic_timeline_ended):
		Dialogic.timeline_ended.disconnect(_on_dialogic_timeline_ended)
	_unlock_dialogic_manual_advance()

func _on_intro_sound_finished() -> void:
	if _is_starting and is_instance_valid(intro_sound_player):
		intro_sound_player.play()
