extends Node

const POOL_SIZE := 8

const SOUNDS := {
	"shoot": "res://assets/sfx/shoot.wav",
	"hit": "res://assets/sfx/hit.wav",
	"enemy_die": "res://assets/sfx/enemy_die.wav",
	"player_hurt": "res://assets/sfx/player_hurt.wav",
	"wave_clear": "res://assets/sfx/wave_clear.wav",
	"click": "res://assets/sfx/click.wav",
	"game_over": "res://assets/sfx/game_over.wav",
	"heal": "res://assets/sfx/heal.wav",
}

var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _streams: Dictionary = {}


func _ready() -> void:
	for path in SOUNDS.values():
		_streams[path] = load(path)
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.volume_db = -6.0
		add_child(player)
		_players.append(player)


func play(sound_name: String) -> void:
	if not SOUNDS.has(sound_name):
		return
	var player := _players[_next]
	_next = (_next + 1) % POOL_SIZE
	player.stream = _streams[SOUNDS[sound_name]]
	player.pitch_scale = randf_range(0.95, 1.05)
	player.play()


func play_shoot() -> void:
	play("shoot")


func play_hit() -> void:
	play("hit")


func play_enemy_die() -> void:
	play("enemy_die")


func play_player_hurt() -> void:
	play("player_hurt")


func play_wave_clear() -> void:
	play("wave_clear")


func play_click() -> void:
	play("click")


func play_game_over() -> void:
	play("game_over")


func play_heal() -> void:
	play("heal")
