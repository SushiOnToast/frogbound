extends Enemy

@onready var damage_timer: Timer = $DamageTimer

@export var stop_distance: float = 10.0
var target_player: Node2D = null

const DAMAGE = 10.0


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	var distance = get_player_distance()
	var player_dir = get_player_direction()

	animate_sprite(player_dir)

	if distance <= stop_distance:
		velocity = Vector2.ZERO
	else:
		velocity = player_dir * speed

	move_and_slide()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		target_player = body
		target_player.take_damage(DAMAGE)
		damage_timer.start()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null
		damage_timer.stop()

func _on_damage_timer_timeout() -> void:
	if is_instance_valid(target_player):
		target_player.take_damage(DAMAGE)
