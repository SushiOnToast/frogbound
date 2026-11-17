class_name Octopus 
extends CharacterBody2D

@export var player: CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shoot_timer: Timer = $ShootTimer
@export var projectileNode: Node2D

signal died

var player_dir: Vector2
const SPEED = 75

var attack_range = 25

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
	
	var to_target := player.global_position - global_position
	if to_target.length() <= attack_range:
		velocity = Vector2.ZERO
		return
	
	velocity = player_dir * SPEED
	move_and_slide()
	

func _on_shoot_timer_timeout() -> void:
	var pellet_scene = load("res://scenes/miscellaenous/octopus_projectile.tscn")
	var pellet = pellet_scene.instantiate()
	pellet.global_position = global_position
	pellet.direction = player_dir
	pellet.target = player
	if projectileNode:
		projectileNode.add_child(pellet)
	
@export var max_health: int = 30
var health: int = max_health

func take_damage(amount: int) -> void:
	health -= amount
	
	animated_sprite_2d.modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.15)
	
	if health <= 0:
		died.emit()
		queue_free()
