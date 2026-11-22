class_name Enemy
extends CharacterBody2D

signal died

@export var player: CharacterBody2D

@export_group("Stats")
@export var max_health: float = Game.DEFAULT_HEALTH
@export var speed: float = Game.DEFAULT_SPEED

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var health: float


func _ready() -> void:
	add_to_group("enemies")
	health = max_health


func get_player_direction() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.ZERO

	return global_position.direction_to(player.global_position)


func get_player_distance() -> float:
	if not is_instance_valid(player):
		return INF

	return global_position.distance_to(player.global_position)


func animate_sprite(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return

	var suffix: String

	if abs(direction.x) > abs(direction.y):
		suffix = "right" if direction.x > 0 else "left"
	else:
		suffix = "down" if direction.y > 0 else "up"

	animated_sprite_2d.play(suffix)


func take_damage(amount: float) -> void:
	health -= amount
	Sfx.play_hit()

	animated_sprite_2d.modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(
		animated_sprite_2d,
		"modulate",
		Color.WHITE,
		0.15
	)

	if health <= 0:
		die()


func die() -> void:
	Sfx.play_enemy_die()
	died.emit()
	queue_free()
