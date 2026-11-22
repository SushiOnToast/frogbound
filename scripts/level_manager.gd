extends Node2D

signal start_cutscene
signal end_cutscene

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	Game.cutscene_playing = true
	start_cutscene.emit()
	player.cutscene_freeze = true
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.show_dialogue_balloon(load("res://dialogue/tutorial.dialogue"), "start")


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	Game.cutscene_playing = false
	end_cutscene.emit()
	player.cutscene_freeze = false
