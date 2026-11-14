extends CharacterBody2D

@export var player: CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@export var projectileNode: Node2D

var player_dir: Vector2
const SPEED = 50

func animate_sprite(direction: Vector2) -> void:
	if direction == Vector2.UP:
		animated_sprite_2d.play("up")
	elif direction == Vector2.DOWN:
		animated_sprite_2d.play("down")
	elif direction == Vector2.LEFT:
		animated_sprite_2d.play("left")
	elif direction == Vector2.RIGHT:
		animated_sprite_2d.play("right")
		
func _ready() -> void:
	add_to_group("enemies")
	add_to_group("octopi")
	

func _physics_process(delta: float) -> void:
	player_dir = position.direction_to(player.position)
	animate_sprite(player_dir)
	
	velocity = player_dir * SPEED
	move_and_slide()
	

func _on_shoot_timer_timeout() -> void:
	var pellet_scene = load("res://scenes/octopus_projectile.tscn")
	var pellet = pellet_scene.instantiate()
	pellet.position = position
	pellet.direction = player_dir
	projectileNode.add_child(pellet)
