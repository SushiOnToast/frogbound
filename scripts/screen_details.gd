extends CanvasLayer

@onready var wave_label: Label = $"Wave Label"
@onready var score_label: Label = $"Score Label"

var _home_position: Vector2
var _home_scale: Vector2
var _tween: Tween

func _ready() -> void:
	await get_tree().process_frame
	_home_position = wave_label.position
	_home_scale = wave_label.scale
	wave_label.pivot_offset = wave_label.size / 2.0

	wave_label.text = "Wave " + str(Game.wave)
	Game.wave_changed.connect(_on_wave_changed)

func _process(delta: float) -> void:
	score_label.text = str(Game.score) + " pts"

func _on_wave_changed(new_wave: int) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()

	wave_label.text = "Wave " + str(new_wave - 1)

	var screen_size := get_viewport().get_visible_rect().size
	var centre_position := (screen_size - wave_label.size) / 2.0

	_tween = create_tween()

	_tween.set_parallel(true)
	_tween.tween_property(wave_label, "position", centre_position, 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(wave_label, "scale", _home_scale * 3.0, 0.5) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_tween.chain().tween_callback(func(): wave_label.text = "Wave " + str(new_wave))
	
	_tween.tween_interval(1.5)
	_tween.tween_property(wave_label, "scale", _home_scale * 3.4, 0.12)
	_tween.tween_property(wave_label, "scale", _home_scale * 3.0, 0.12)

	_tween.set_parallel(true)
	_tween.tween_property(wave_label, "position", _home_position, 0.5) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(wave_label, "scale", _home_scale, 0.5) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
