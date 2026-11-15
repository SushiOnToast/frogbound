extends CharacterBody2D

signal died

enum State { CHASE, CHARGE, ATTACK, COOLDOWN }

@export var max_health := 200.0
@export var hop_speed := 90.0        
@export var attack_range := 25.0  
@export var attack_damage := 20.0
@export var attack_cooldown := 1.5  # rest time after an attack
@export var hit_frame := 2      

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

@export var player: Node2D  
var health: float
var state := State.CHASE
var hurt := false
var hit_landed := false

var dying := false

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	attack_area.monitoring = false
	sprite.play("idle")

func _physics_process(_delta: float) -> void:
	if hurt or state != State.CHASE or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return

	var to_target := player.global_position - global_position
	if to_target.length() <= attack_range:
		_start_attack()
		return

	var dir := to_target.normalized()
	sprite.flip_h = dir.x > 0   # art faces left, so flip when moving right
	if sprite.animation != "jump" and not dying:
		sprite.play("jump")
	
	if dying:
		die()
		return

	# Speed follows the hop: still on take-off and landing, fastest mid-air
	var frames := sprite.sprite_frames.get_frame_count("jump")
	var t := float(sprite.frame) / maxf(frames - 1, 1)
	velocity = dir * hop_speed * sin(t * PI)
	move_and_slide()

func _start_attack() -> void:
	state = State.CHARGE
	velocity = Vector2.ZERO
	sprite.flip_h = player.global_position.x > global_position.x
	sprite.play("charge")
	await sprite.animation_finished   # pauses for exactly the charge animation

	state = State.ATTACK
	hit_landed = false
	sprite.play("attack")
	await sprite.animation_finished
	attack_area.set_deferred("monitoring", false)

	state = State.COOLDOWN
	sprite.play("idle")
	await get_tree().create_timer(attack_cooldown).timeout
	state = State.CHASE

# Hitbox turns on only at the frame where the slam visually lands
func _on_animated_sprite_2d_frame_changed() -> void:
	if state == State.ATTACK and sprite.animation == "attack" and sprite.frame == hit_frame:
		attack_area.set_deferred("monitoring", true)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if hit_landed or not body.is_in_group("player"):
		return
	hit_landed = true   # one hit per attack
	if body.has_method("take_damage"):
		body.take_damage(attack_damage)
		
func die():
	sprite.play("die")
	await sprite.animation_finished
	died.emit()
	queue_free()

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		dying = true
		return

	if state == State.CHARGE or state == State.ATTACK:
		sprite.modulate = Color(1, 0.5, 0.5)
		create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.15)
	else:
		hurt = true
		sprite.play("hit")
		await sprite.animation_finished
		hurt = false
		if state == State.COOLDOWN:
			sprite.play("idle")
