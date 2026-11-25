extends Node

signal score_changed(new_score: int)
signal wave_changed(new_wave: int)
signal state_changed(new_state: State)

enum State { MENU, PLAYING, PAUSED, GAME_OVER }

const ENEMIES := {
	"lizard":  {"scene": "res://scenes/mobs/lizard.tscn",  "unlock_wave": 1, "cost": 1, "weight": 10, "points": 10},
	"octopus": {"scene": "res://scenes/mobs/red_octopus.tscn", "unlock_wave": 2, "cost": 2, "weight": 4,  "points": 30},
	"t_rex":   {"scene": "res://scenes/mobs/t_rex.tscn",   "unlock_wave": 3, "cost": 2, "weight": 5,  "points": 50},
}

const MINIBOSS := {
	"scene": "res://scenes/mobs/bossfrog.tscn",
	"enabled": true,
	"first_wave": 5,
	"points": 9000,
}

const LEVEL_SCENE := "res://scenes/level.tscn"
const MENU_SCENE := "res://scenes/UI/menu_screen.tscn"
const GAME_OVER_SCENE := "res://scenes/UI/game_over_screen.tscn"
const PAUSE_SCREEN_SCENE := "res://scenes/UI/pause_screen.tscn"

var cutscene_playing := false

var wave := 0
var score := 0
var state: State = State.MENU

const HIGH_SCORE_PATH := "user://high_score.txt"
var high_score := 0
var is_new_high_score := false

const DEFAULT_SPEED := 100.0
const DEFAULT_HEALTH := 30.0

var _pause_layer: CanvasLayer = null

func _ready() -> void:
	# The manager shuodl keep receiving input while the tree is paused otherwise esc wouldnt unpause the game
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_high_score()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if state == State.PLAYING:
			pause_game()
		elif state == State.PAUSED:
			resume_game()


func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	state_changed.emit(state)


func start_game() -> void:
	Sfx.play_click()
	reset()
	_free_pause_overlay()
	get_tree().paused = false
	_set_state(State.PLAYING)
	get_tree().change_scene_to_file(LEVEL_SCENE)


func pause_game() -> void:
	if state != State.PLAYING:
		return
	_set_state(State.PAUSED)
	get_tree().paused = true
	_show_pause_overlay()


func resume_game() -> void:
	if state != State.PAUSED:
		return
	_free_pause_overlay()
	get_tree().paused = false
	_set_state(State.PLAYING)


func toggle_pause() -> void:
	if state == State.PLAYING:
		pause_game()
	elif state == State.PAUSED:
		resume_game()


func game_over() -> void:
	if state == State.GAME_OVER:
		return
	Sfx.play_game_over()
	_free_pause_overlay()
	get_tree().paused = false
	_set_state(State.GAME_OVER)
	
	if score > high_score:
		high_score = score
		is_new_high_score = true
		_save_high_score()
	else:
		is_new_high_score = false
		
	get_tree().change_scene_to_file.call_deferred(GAME_OVER_SCENE)


func to_menu() -> void:
	_free_pause_overlay()
	get_tree().paused = false
	_set_state(State.MENU)
	get_tree().change_scene_to_file(MENU_SCENE)


func mark_playing() -> void:
	_set_state(State.PLAYING)


func _show_pause_overlay() -> void:
	if _pause_layer != null:
		return
	var layer := CanvasLayer.new()
	layer.layer = 10
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	var overlay: Control = load(PAUSE_SCREEN_SCENE).instantiate()
	layer.add_child(overlay)
	get_tree().root.add_child(layer)
	_pause_layer = layer


func _free_pause_overlay() -> void:
	if is_instance_valid(_pause_layer):
		_pause_layer.queue_free()
	_pause_layer = null

func reset() -> void:
	wave = 0
	score = 0
	score_changed.emit(score)
	
	
func next_wave() -> int:
	wave += 1
	wave_changed.emit(wave)
	return wave


func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


func points_for(id: String) -> int:
	if id == "miniboss":
		return MINIBOSS.points
	return ENEMIES[id].points


func scene_for(id: String) -> String:
	if id == "miniboss":
		return MINIBOSS.scene
	return ENEMIES[id].scene
	
	
# more enemies every wave
func wave_budget(w: int) -> int:
	return 4 + w * 2


func miniboss_count(w: int) -> int:
	if w < MINIBOSS.first_wave:
		return 0
	
	var count: int = 1 + ((w - MINIBOSS.first_wave) / 2) 
	return count;
	
	
# randomly picking an enemy that has been unlocked from the list
func pick_enemy(w: int, budget: int) -> String:
	var pool: Array[String] = []
	var total := 0
	for id in ENEMIES:
		var e = ENEMIES[id]
		# first select all valid enemies
		if w >= e.unlock_wave and e.cost <= budget:
			pool.append(id)
			total += e.weight
	if pool.is_empty():
		return ""
	# now select randomly from the available enemies
	var roll := randi_range(1, total)
	for id in pool:
		roll -= ENEMIES[id].weight 
		if roll <= 0:
			return id
	return pool[0]


# Builds the list of enemy ids to spawn for a wave
func build_wave(w: int) -> Array[String]:
	var queue: Array[String] = []
	var budget := wave_budget(w)
	while true:
		var id := pick_enemy(w, budget)
		if id == "":
			break
		budget -= ENEMIES[id].cost
		queue.append(id)
	for i in miniboss_count(w):
		queue.append("miniboss")
	queue.shuffle()
	return queue
	
func _load_high_score() -> void:
	if not FileAccess.file_exists(HIGH_SCORE_PATH):
		return
	var file:= FileAccess.open(HIGH_SCORE_PATH, FileAccess.READ)
	high_score = int(file.get_as_text().strip_edges())
	
func _save_high_score() -> void:
	var file := FileAccess.open(HIGH_SCORE_PATH, FileAccess.WRITE)
	file.store_string(str(high_score))
