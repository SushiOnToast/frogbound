extends CharacterBody2D

@export var player: CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@export var projectileNode: Node2D

signal died

var player_dir: Vector2
const SPEED = 75

func animate_sprite(direction: Vector2) -> void:
	var suffix: String
	if abs(direction.x) > abs(direction.y):
		suffix = "right" if direction.x > 0 else "left"
	else:
		suffix = "down" if direction.y > 0 else "up"
	animated_sprite_2d.play(suffix)
		
func _ready() -> void:
	add_to_group("enemies")
	add_to_group("octopi")
	

func _physics_process(_delta: float) -> void:
	player_dir = position.direction_to(player.position)
	animate_sprite(player_dir)
	
	velocity = player_dir * SPEED
	move_and_slide()
	

func _on_shoot_timer_timeout() -> void:
	var pellet_scene = load("res://scenes/octopus_projectile.tscn")
	var pellet = pellet_scene.instantiate()
	pellet.global_position = global_position
	pellet.direction = player_dir
	pellet.target = player
	projectileNode.add_child(pellet)
