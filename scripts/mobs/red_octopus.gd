class_name Octopus
extends Enemy

@onready var shoot_timer: Timer = $ShootTimer

@export var projectile_node: Node2D

const ATTACK_RANGE = 25.0


func _ready() -> void:
	super._ready()
	speed = 75.0


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	var player_dir = get_player_direction()
	animate_sprite(player_dir)

	if get_player_distance() <= ATTACK_RANGE:
		velocity = Vector2.ZERO
		return

	velocity = player_dir * speed
	move_and_slide()


func _on_shoot_timer_timeout() -> void:
	if not is_instance_valid(player):
		return

	var pellet_scene = load(
		"res://scenes/miscellaenous/octopus_projectile.tscn"
	)

	var pellet = pellet_scene.instantiate()
	pellet.global_position = global_position
	pellet.direction = get_player_direction()
	pellet.target = player

	if is_instance_valid(projectile_node):
		projectile_node.add_child(pellet)
