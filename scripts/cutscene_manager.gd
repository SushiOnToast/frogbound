extends Node

signal cutscene_started
signal cutscene_finished

const DIALOGUE_BOX_SCENE := "res://scenes/UI/dialogue_box.tscn"

var playing := false

var _dialogue_box: Control = null
var _banner_label: Label = null
var _skip_requested := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if playing and event.is_action_pressed("pause"):
		_skip_requested = true

func play(steps: Array) -> void:
	if playing:
		return
	playing = true
	_skip_requested = false
	cutscene_started.emit()

	var was_paused := get_tree().paused
	get_tree().paused = true
	_show_overlay()

	for step in steps:
		if _skip_requested:
			break
		match step.get("kind", ""):
			"banner":
				await _play_banner(step)
			"wait":
				await _wait(float(step.get("seconds", 1.0)))
			"dialogue":
				await _play_dialogue(step)
			"dialogue_resource":
				await _play_dialogue_resource(step)
			_:
				push_warning("Cutscene: unknown step kind '%s'" % step.get("kind", ""))

	_hide_overlay()
	get_tree().paused = was_paused
	playing = false
	cutscene_finished.emit()


func play_banner(text: String, seconds: float = 2.0) -> void:
	await play([{"kind": "banner", "text": text, "seconds": seconds}])


func _show_overlay() -> void:
	if _dialogue_box == null and ResourceLoader.exists(DIALOGUE_BOX_SCENE):
		_dialogue_box = load(DIALOGUE_BOX_SCENE).instantiate()
		_dialogue_box.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(_dialogue_box)
		_dialogue_box.hide_box()

	if _banner_label == null:
		var canvas := CanvasLayer.new()
		canvas.layer = 10
		canvas.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(canvas)
		_banner_label = Label.new()
		_banner_label.visible = false
		_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_banner_label.add_theme_font_size_override("font_size", 40)
		canvas.add_child(_banner_label)
		_banner_label.set_anchors_preset(Control.PRESET_CENTER)
		_banner_label.position = Vector2(-400, -100)
		_banner_label.size = Vector2(800, 200)



func _hide_overlay() -> void:
	if _dialogue_box != null:
		_dialogue_box.hide_box()
	if _banner_label != null:
		_banner_label.visible = false


func _play_banner(step: Dictionary) -> void:
	_banner_label.text = str(step.get("text", ""))
	_banner_label.visible = true
	await _wait(float(step.get("seconds", 2.0)))
	_banner_label.visible = false


func _play_dialogue(step: Dictionary) -> void:
	#SUSHI GOT THISSSS
	if _dialogue_box == null:
		push_warning("TODOOOO")
		return
	_dialogue_box.show_line(str(step.get("speaker", "")), str(step.get("text", "")))
	await _dialogue_box.line_finished
	_dialogue_box.hide_box()


func _play_dialogue_resource(step: Dictionary) -> void:
	#SUSHI GOT THIS TOOOOOOO
	push_warning("TODOO")
	return


func _wait(seconds: float) -> void:
	# process_always=true so the wait actually elapses while paused
	await get_tree().create_timer(seconds, true).timeout
