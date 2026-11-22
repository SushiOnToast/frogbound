extends Control

@onready var frog_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_center_frog()
	get_viewport().size_changed.connect(_center_frog)


func _center_frog() -> void:
	var size := get_viewport_rect().size
	frog_sprite.position = Vector2(size.x * 0.5, size.y * 0.37)


func _input(_event):
	if Input.is_action_just_pressed("menu_interact"):
		start_game()


func start_game():
	Game.start_game()
