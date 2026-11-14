extends Node2D

@export var player: CharacterBody2D

func _ready() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		enemy.player = player
