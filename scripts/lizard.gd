extends CharacterBody2D

@export var player: CharacterBody2D
@export var max_health: int = 30

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var damage_timer = $DamageTimer

signal died

var health: int
var player_dir: Vector2
var target_player: Node2D = null
const SPEED = 100
const DAMAGE = 10

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

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	player_dir = position.direction_to(player.position)
	animate_sprite(player_dir)
	
	velocity = player_dir * SPEED
	move_and_slide()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		target_player = body
		target_player.take_damage(DAMAGE) # Immediate bite on contact
		damage_timer.start()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null
		damage_timer.stop()

func _on_damage_timer_timeout() -> void:
	if is_instance_valid(target_player):
		target_player.take_damage(DAMAGE)

func take_damage(amount: int) -> void:
	health -= amount
	
	animated_sprite_2d.modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.15)
	
	if health <= 0:
		died.emit()
		queue_free()

func _on_timer_timeout() -> void:
	pass # Replace with function body.
