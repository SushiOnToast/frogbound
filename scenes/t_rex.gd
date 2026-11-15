extends CharacterBody2D

@export var player: CharacterBody2D
@export var stop_distance: float = 50.0 
@export var max_health: int = 80

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var fire_area = $FireArea
@onready var fire_sprite = $FireArea/AnimatedSprite2D

signal died

var health: int
var player_dir: Vector2
var is_attacking: bool = false
const SPEED = 100
const FIRE_DAMAGE = 10

func animate_sprite(direction: Vector2) -> void:
	var suffix: String
	if abs(direction.x) > abs(direction.y):
		suffix = "right" if direction.x > 0 else "left"
	else:
		suffix = "down" if direction.y > 0 else "up"

	animated_sprite_2d.play(suffix)

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	fire_area.visible = false

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	var distance = global_position.distance_to(player.global_position)
	player_dir = global_position.direction_to(player.global_position)

	if distance > stop_distance:
		stop_fire()
		velocity = player_dir * SPEED
	else:
		breathe_fire()
		velocity = Vector2.ZERO

	animate_sprite(player_dir)
	move_and_slide()
	
func breathe_fire() -> void:
	if not is_attacking:
		is_attacking = true
		fire_area.visible = true
		fire_sprite.play()
	# rotates the fire hitbox so it always points at the player
	fire_area.rotation = player_dir.angle() - PI / 2
	
func stop_fire() -> void:
	is_attacking = false
	fire_area.visible = false
	
func _on_fire_damage_timer_timeout() -> void:
	# only does damage if the dragon is close and the player is inside the fire hitbox
	if not is_attacking:
		return
	for body in fire_area.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(FIRE_DAMAGE)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		died.emit()
		queue_free()
