extends Enemy

@onready var damage_timer: Timer = $DamageTimer

@export var stop_distance: float = 12.0
var target_player: Node2D = null

const DAMAGE = 10.0
const DAMAGE_INTERVAL := 0.62
const STUCK_SPEED_FRACTION := 0.25
const UNSTICK_TIME := 0.35

var _unstick_timer := 0.0
var _unstick_dir := Vector2.ZERO


func _ready() -> void:
	super._ready()
	damage_timer.wait_time = DAMAGE_INTERVAL
	damage_timer.one_shot = false
	damage_timer.autostart = false
	damage_timer.timeout.connect(_on_damage_timer_timeout)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var distance = get_player_distance()
	var player_dir: Vector2 = get_player_direction()

	animate_sprite(player_dir)

	if distance <= stop_distance:
		velocity = Vector2.ZERO
	else:
		var move_dir: Vector2 = player_dir
		if _unstick_timer > 0.0:
			_unstick_timer -= delta
			move_dir = (player_dir + _unstick_dir).normalized()
		velocity = move_dir * speed

	move_and_slide()

	if distance > stop_distance and velocity != Vector2.ZERO \
			and get_real_velocity().length() < speed * STUCK_SPEED_FRACTION \
			and _unstick_timer <= 0.0:
		_unstick_timer = UNSTICK_TIME
		if get_slide_collision_count() > 0:
			var normal := get_slide_collision(0).get_normal()
			_unstick_dir = Vector2(-normal.y, normal.x)
		else:
			_unstick_dir = Vector2(-player_dir.y, player_dir.x)

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
	else:
		damage_timer.stop()
