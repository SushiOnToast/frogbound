extends Enemy

enum State { CHASE, CHARGE, ATTACK, COOLDOWN }

@export_group("Boss Stats")
@export var hop_speed: float = 90.0
@export var attack_range: float = 25.0
@export var attack_damage: float = 50.0
@export var attack_cooldown: float = 1.5
@export var hit_frame: int = 2

@onready var attack_area: Area2D = $AttackArea

var state := State.CHASE
var hurt := false
var hit_landed := false
var dying := false


func _ready() -> void:
	max_health = 200.0
	super._ready()
	
	attack_area.monitoring = false
	animated_sprite_2d.play("idle")


func _physics_process(_delta: float) -> void:
	if dying or hurt or state != State.CHASE or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return

	var to_target := player.global_position - global_position

	if to_target.length() <= attack_range:
		_start_attack()
		return

	var dir := to_target.normalized()

	# Art faces left, so flip when moving right
	animated_sprite_2d.flip_h = dir.x > 0

	if animated_sprite_2d.animation != "jump":
		animated_sprite_2d.play("jump")

	# Speed follows the hop animation
	var frames := animated_sprite_2d.sprite_frames.get_frame_count("jump")
	var t := float(animated_sprite_2d.frame) / maxf(frames - 1, 1)

	velocity = dir * hop_speed * sin(t * PI)
	move_and_slide()


func _start_attack() -> void:
	state = State.CHARGE
	velocity = Vector2.ZERO

	attack_area.set_deferred("monitoring", false)

	animated_sprite_2d.flip_h = player.global_position.x > global_position.x
	animated_sprite_2d.play("charge")

	await animated_sprite_2d.animation_finished

	if dying:
		return

	state = State.ATTACK
	hit_landed = false
	animated_sprite_2d.play("attack")

	await animated_sprite_2d.animation_finished

	if dying:
		return

	attack_area.set_deferred("monitoring", false)

	state = State.COOLDOWN
	animated_sprite_2d.play("idle")

	await get_tree().create_timer(attack_cooldown).timeout

	if dying:
		return

	state = State.CHASE


# Enable hitbox only when the slam visually lands
func _on_animated_sprite_2d_frame_changed() -> void:
	if state == State.ATTACK \
	and animated_sprite_2d.animation == "attack" \
	and animated_sprite_2d.frame == hit_frame:
		attack_area.set_deferred("monitoring", true)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if hit_landed or not body.is_in_group("player"):
		return

	hit_landed = true

	if body.has_method("take_damage"):
		body.take_damage(attack_damage)


# Override base damage behaviour for the boss's hit animation
func take_damage(amount: float) -> void:
	if dying:
		return

	health -= amount
	Sfx.play_hit()

	if health <= 0:
		dying = true
		velocity = Vector2.ZERO
		attack_area.set_deferred("monitoring", false)
		die()
		return

	if hurt:
		return

	hurt = true
	animated_sprite_2d.play("hit")

	await animated_sprite_2d.animation_finished

	if dying:
		return

	hurt = false

	if state == State.COOLDOWN:
		animated_sprite_2d.play("idle")


func die() -> void:
	Sfx.play_enemy_die()
	animated_sprite_2d.play("die")

	await animated_sprite_2d.animation_finished
	
	_spawn_health_pack()
	died.emit()
	queue_free()

func _spawn_health_pack() -> void:
	if randf() >= 0.6:
		return
	var pack = load("res://scenes/miscellaenous/health_pack.tscn").instantiate()
	pack.global_position = global_position
	get_parent().add_child(pack)
