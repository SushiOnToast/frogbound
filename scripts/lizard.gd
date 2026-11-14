extends CharacterBody2D

@export var player: CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D

signal died

var player_dir: Vector2
const SPEED = 100

func animate_sprite(direction: Vector2) -> void:
	var suffix: String
	if abs(direction.x) > abs(direction.y):
		suffix = "right" if direction.x > 0 else "left"
	else:
		suffix = "down" if direction.y > 0 else "up"
	animated_sprite_2d.play(suffix)
		
func _ready() -> void:
	add_to_group("enemies")

func _physics_process(_delta: float) -> void:
	player_dir = position.direction_to(player.position)
	animate_sprite(player_dir)
	
	velocity = player_dir * SPEED
	move_and_slide()
	
