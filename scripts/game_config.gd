extends Node

signal score_changed(new_score: int)
signal wave_changed(new_wave: int)

const ENEMIES := {
	"lizard":  {"scene": "res://scenes/lizard.tscn",  "unlock_wave": 1, "cost": 1, "weight": 10, "points": 10},
	"octopus": {"scene": "res://scenes/octopus.tscn", "unlock_wave": 3, "cost": 3, "weight": 4,  "points": 30},
	"t_rex":   {"scene": "res://scenes/t_rex.tscn",   "unlock_wave": 2, "cost": 4, "weight": 5,  "points": 50},
	"spider":  {"scene": "res://scenes/spider_range.tscn",  "unlock_wave": 1, "cost": 2, "weight": 8,  "points": 20},
}

const MINIBOSS := {
	"scene": "res://scenes/bossfrog.tscn",
	"enabled": true,
	"first_wave": 5,
	"every": 3,
	"points": 150,
}

var wave := 0
var score := 0

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
	return 5 + w * 3

func miniboss_count(w: int) -> int:
	if not MINIBOSS.enabled or w < MINIBOSS.first_wave:
		return 0
	return 1 if (w - MINIBOSS.first_wave) % MINIBOSS.every == 0 else 0

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
