extends Node

@export var player: Node2D
@export var projectileNode: Node2D

const MAP_MIN := Vector2(-540, -440)
const MAP_MAX := Vector2(636, 636)
const SPAWN_INTERVAL := 0.4
const WAVE_BREAK := 2.0

var alive := 0
var spawning := false
var between_waves := false

func _ready() -> void:
	Game.reset()
	for id in ["lizard", "octopus", "t_rex", "miniboss"]:
		load(Game.scene_for(id))
	if Game.state != Game.State.PLAYING:
		Game.mark_playing()
	start_next_wave()
	
func start_next_wave() -> void:
	if Game.state != Game.State.PLAYING:
		return
	between_waves = false
	var wave_number := Game.next_wave()
	if not is_inside_tree() or Game.state != Game.State.PLAYING:
		await _wait_until_playing()
		if not is_inside_tree():
			return
	var queue := Game.build_wave(wave_number)

	spawning = true
	for id in queue:
		spawn_enemy(id)
		await get_tree().create_timer(SPAWN_INTERVAL, false).timeout
		if not is_inside_tree():
			spawning = false
			return
		if Game.state != Game.State.PLAYING:
			await _wait_until_playing()
			if not is_inside_tree():
				spawning = false
				return
	spawning = false
	_check_wave_done()

func spawn_enemy(id: String) -> void:
	var enemy = load(Game.scene_for(id)).instantiate()
	enemy.global_position = random_spawn_pos()
	enemy.player = player
	enemy.died.connect(_on_enemy_died.bind(id))
	if enemy is Octopus:
		enemy.projectile_node = projectileNode
	alive += 1
	add_child(enemy)
	
func random_spawn_pos() -> Vector2:
	var pos := Vector2.ZERO
	for i in 10:
		pos = player.global_position + Vector2.from_angle(randf() * TAU) * randf_range(350, 450)
		pos = pos.clamp(MAP_MIN, MAP_MAX)
		if pos.distance_to(player.global_position) > 250:
			break
	return pos

func _on_enemy_died(id: String) -> void:
	Game.add_score(Game.points_for(id))
	alive -= 1
	_check_wave_done()

func _check_wave_done() -> void:
	if alive > 0 or spawning or between_waves:
		return
	Sfx.play_wave_clear()
	between_waves = true
	await get_tree().create_timer(WAVE_BREAK, false).timeout
	if not is_inside_tree() or Game.state != Game.State.PLAYING:
		return
	start_next_wave()
	
func _wait_until_playing() -> void:
	while is_inside_tree() and Game.state != Game.State.PLAYING:
		await Game.state_changed
