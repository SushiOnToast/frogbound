extends Control

func _input(_event):
	if Input.is_action_just_pressed("menu_interact"):
		start_game()

func start_game():		
	get_tree().change_scene_to_file("res://scenes/level.tscn")
