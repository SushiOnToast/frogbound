extends Node2D

@export var player: CharacterBody2D
@export var projectileNode: Node2D

func _ready() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		enemy.player = player
		
		if enemy.is_in_group("octopi"):
			enemy.projectileNode = projectileNode
