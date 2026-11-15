extends CharacterBody2D

@export var player: CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D

signal died

var player_dir: Vector2
const SPEED = 100

var attack_range = 10

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
	
	var to_target := player.global_position - global_position
	if to_target.length() <= attack_range:
		velocity = Vector2.ZERO
		return
		
		
	
	velocity = player_dir * SPEED
	move_and_slide()
	
@export var max_health: int = 30
var health: int = max_health

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		died.emit()
		queue_free()
