extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hearts_bar = $CanvasLayer/HeartsBar
@onready var health_label = $CanvasLayer/HealthLabel

const MAX_HEALTH = 100

const HEART_HP := 10
const HEART_COUNT := MAX_HEALTH / HEART_HP
const HEART_SIZE := Vector2(27, 24)
const HEART_FULL_COLOR := Color(0.93, 0.11, 0.09)
const HEART_OUTLINE_COLOR := Color(0.42, 0.03, 0.03)
const HEART_HIGHLIGHT_COLOR := Color(1.0, 0.85, 0.82)
const HEART_EMPTY_COLOR := Color(0.32, 0.32, 0.35)
const HEART_EMPTY_OUTLINE_COLOR := Color(0.14, 0.14, 0.16)

const HEART_PIXELS: Array[String] = [
	".ORRORRO.",
	"ORWRRRRRO",
	"ORRRRRRRO",
	"ORRRRRRRO",
	".ORRRRRO.",
	"..ORRRO..",
	"...ORO...",
	"....O....",
]
const HEART_PIXEL_SCALE := 3

var _heart_full_texture: Texture2D
var _heart_half_texture: Texture2D
var _heart_empty_texture: Texture2D

# Below this health the hearts pulse red so low health is obvious.
const LOW_HEALTH := 30

const SHURIKEN_SCENE = preload("res://scenes/miscellaenous/shuriken.tscn")
const SPEED = 150

var health: int = MAX_HEALTH
var perm_direction: Vector2
var animation: String = "idle"
var _displayed_health: float = MAX_HEALTH
var _hearts: Array[TextureRect] = []

func _ready() -> void:
	add_to_group("player")
	_heart_full_texture = _make_heart_texture(true, false)
	_heart_half_texture = _make_heart_texture(true, true)
	_heart_empty_texture = _make_heart_texture(false, false)
	_build_hearts()
	_update_health_ui()
	health

static func _make_heart_texture(filled: bool, half: bool) -> Texture2D:
	var w := 9 * HEART_PIXEL_SCALE
	var h := 8 * HEART_PIXEL_SCALE
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for gy in 8:
		for gx in 9:
			var cell: String = HEART_PIXELS[gy][gx]
			if cell == ".":
				continue
			var use_filled := filled and (not half or gx < 5)
			var col: Color
			if cell == "O":
				col = HEART_OUTLINE_COLOR if use_filled else HEART_EMPTY_OUTLINE_COLOR
			elif cell == "W":
				col = HEART_HIGHLIGHT_COLOR if use_filled else HEART_EMPTY_COLOR
			else:  # "R"
				col = HEART_FULL_COLOR if use_filled else HEART_EMPTY_COLOR
			for py in HEART_PIXEL_SCALE:
				for px in HEART_PIXEL_SCALE:
					img.set_pixel(gx * HEART_PIXEL_SCALE + px, gy * HEART_PIXEL_SCALE + py, col)
	return ImageTexture.create_from_image(img)

static func movement_input() -> Vector2:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
		
	return direction
	

func animate_sprite(anim: String, direction: Vector2) -> void:
	var suffix: String
	if abs(direction.x) > abs(direction.y):
		suffix = "right" if direction.x > 0 else "left"
	else:
		suffix = "down" if direction.y > 0 else "up"
	animated_sprite_2d.play("%s_%s" % [anim, suffix])
	

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = movement_input()
		
	if direction != Vector2.ZERO:
		perm_direction = direction
		animation = "walk"
	else:
		animation = "idle"
	
	_update_healthbar_pulse()
	animate_sprite(animation, perm_direction)
	
	velocity = direction * SPEED
	move_and_slide()
	if Input.is_action_just_pressed("shoot"):
		throw_shuriken()
	
func throw_shuriken() -> void:
	Sfx.play_shoot()
	var shuriken = SHURIKEN_SCENE.instantiate()
	shuriken.global_position = global_position
	# aims toward the mouse
	shuriken.direction = global_position.direction_to(get_global_mouse_position())
	get_parent().add_child(shuriken)
	
func take_damage(amount: int) -> void:
	health = clampi(health - amount, 0, MAX_HEALTH)
	Sfx.play_player_hurt()

	animated_sprite_2d.modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.15)

	if hearts_bar:
		_animate_hearts_to(health)
		hearts_bar.modulate = Color(1, 0.45, 0.45)
		create_tween().tween_property(hearts_bar, "modulate", Color.WHITE, 0.25)
	_update_health_ui()

	if health <= 0:
		die()

func heal(amount: int) -> void:
	health = clampi(health + amount, 0, MAX_HEALTH)
	Sfx.play_heal()
	if hearts_bar:
		_animate_hearts_to(health)
	_update_health_ui()


func _build_hearts() -> void:
	if hearts_bar == null:
		return
	for i in HEART_COUNT:
		var heart := TextureRect.new()
		heart.texture = _heart_full_texture
		heart.custom_minimum_size = HEART_SIZE
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hearts_bar.add_child(heart)
		_hearts.append(heart)
	_update_hearts()


func _update_hearts() -> void:
	if _hearts.is_empty():
		return
	var hp := int(round(_displayed_health / 5.0)) * 5
	for i in _hearts.size():
		var heart_hp := hp - i * HEART_HP
		var heart := _hearts[i]
		if heart_hp >= HEART_HP:
			heart.texture = _heart_full_texture
		elif heart_hp >= HEART_HP / 2:
			heart.texture = _heart_half_texture
		else:
			heart.texture = _heart_empty_texture


func _animate_hearts_to(target: int) -> void:
	var tween := create_tween()
	tween.tween_method(_set_displayed_health, _displayed_health, float(target), 0.2)


func _set_displayed_health(value: float) -> void:
	_displayed_health = value
	_update_hearts()


func _update_health_ui() -> void:
	if health_label:
		health_label.text = "%d / %d" % [health, MAX_HEALTH]


func _update_healthbar_pulse() -> void:
	if hearts_bar == null:
		return
	if health > 0 and health <= LOW_HEALTH:
		var pulse := 0.65 + 0.35 * sin(Time.get_ticks_msec() / 150.0)
		hearts_bar.self_modulate = Color(1, pulse, pulse)
	else:
		hearts_bar.self_modulate = Color.WHITE
	
func die() -> void:
	Game.game_over()
