extends Enemy

@export var stop_distance: float = 30.0
@export var chase_distance: float = 55.0

@onready var fire_area: Area2D = $FireArea
@onready var fire_sprite: AnimatedSprite2D = $FireArea/AnimatedSprite2D

var is_attacking: bool = false

const FIRE_DAMAGE = 10.0


func _ready() -> void:
	max_health = 80.0
	super._ready()
	
	fire_area.visible = false
	fire_sprite.animation_finished.connect(
		_on_fire_sprite_animation_finished
	)


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	var distance = get_player_distance()
	var player_dir = get_player_direction()

	if fire_area.visible:
		fire_area.rotation = player_dir.angle() - PI / 2

	if is_attacking:
		if distance > chase_distance:
			stop_fire()
			velocity = player_dir * speed
		else:
			breathe_fire()
			velocity = Vector2.ZERO
	else:
		if distance <= stop_distance:
			breathe_fire()
			velocity = Vector2.ZERO
		else:
			velocity = player_dir * speed

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

	var dist := get_player_distance()
	var angle_diff := absf(
		get_player_direction().angle_to(
			global_position.direction_to(player.global_position)
		)
	)

	if dist <= chase_distance + 15.0 and angle_diff < 0.7:
		if player.has_method("take_damage"):
			player.take_damage(FIRE_DAMAGE)


func _on_fire_damage_timer_timeout() -> void:
	if is_attacking:
		deal_fire_damage()
