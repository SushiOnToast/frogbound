extends CharacterBody2D

@export var player: CharacterBody2D
@export var stop_distance: float = 30.0
@export var chase_distance: float = 55.0
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
	fire_sprite.animation_finished.connect(_on_fire_sprite_animation_finished)
	
func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	var distance = global_position.distance_to(player.global_position)
	player_dir = global_position.direction_to(player.global_position)
	
	if fire_area.visible:
		fire_area.rotation = player_dir.angle() - PI / 2

	if is_attacking:
		if distance > chase_distance:
			stop_fire()
			velocity = player_dir * SPEED
		else:
			breathe_fire()
			velocity = Vector2.ZERO
	else:
		if distance <= stop_distance:
			breathe_fire()
			velocity = Vector2.ZERO
		else:
			velocity = player_dir * SPEED

	animate_sprite(player_dir)
	move_and_slide()

func breathe_fire() -> void:
	if not is_attacking:
		is_attacking = true
		fire_area.visible = true
		fire_sprite.frame = 0
		fire_sprite.play()
		deal_fire_damage()

func stop_fire() -> void:
	is_attacking = false
	
func _on_fire_sprite_animation_finished() -> void:
	if not is_attacking:
		fire_area.visible = false

func deal_fire_damage() -> void:
	if not is_instance_valid(player):
		return
	var dist := global_position.distance_to(player.global_position)
	var angle_diff := absf(player_dir.angle_to(global_position.direction_to(player.global_position)))
	if dist <= chase_distance + 15.0 and angle_diff < 0.7 and player.has_method("take_damage"):
		player.take_damage(FIRE_DAMAGE)

func _on_fire_damage_timer_timeout() -> void:
	if is_attacking:
		deal_fire_damage()
		

func take_damage(amount: int) -> void:
	health -= amount
	
	animated_sprite_2d.modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.15)
	
	if health <= 0:
		died.emit()
		queue_free()
