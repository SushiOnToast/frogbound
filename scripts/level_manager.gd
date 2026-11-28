extends Node2D

signal start_cutscene
signal end_cutscene

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var player: CharacterBody2D = $Player
@onready var overlay: CanvasLayer = $Overlay
@onready var map: Node2D = $map


func _ready() -> void:
	Game.cutscene_playing = true
	player.cutscene_freeze = true
	move_player_above(true)
	start_cutscene.emit()
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon(
		load("res://dialogue/tutorial.dialogue"),
		"start",
		[self]
	)

func move_player_above(above: bool):
	var camera: Camera2D = player.get_node("Camera2D")
	
	if above:
		map.modulate = Color.BLACK
	else:
		var tween = create_tween()
		tween.tween_property(map, "modulate", Color.WHITE, 0.2)
		await tween.finished
		
		await get_tree().create_timer(0.5).timeout

func movement_tutorial():
	player.cutscene_freeze = false

	var previous_position = player.global_position
	var distance_travelled = 0.0

	while distance_travelled < 500.0:
		await get_tree().process_frame

		var current_position = player.global_position
		distance_travelled += previous_position.distance_to(current_position)
		previous_position = current_position

	player.cutscene_freeze = true
	player.animate_sprite("idle", Vector2.DOWN)

func _on_dialogue_ended(_resource: DialogueResource) -> void:
	Game.cutscene_playing = false
	end_cutscene.emit()
	player.cutscene_freeze = false
	player.perm_direction = Vector2.DOWN
