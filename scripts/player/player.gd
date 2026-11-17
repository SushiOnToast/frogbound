extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var health_bar = $CanvasLayer/Healthbar



const SHURIKEN_SCENE = preload("res://scenes/miscellaenous/shuriken.tscn")
const SPEED = 150
const MAX_HEALTH = 100

var health: int = MAX_HEALTH
var perm_direction: Vector2
var animation: String = "idle"

func _ready() -> void:
	add_to_group("player")
	if health_bar:
		health_bar.max_value = MAX_HEALTH
		health_bar.value = health

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
	
	animate_sprite(animation, perm_direction)
	
	velocity = direction * SPEED
	move_and_slide()
	if Input.is_action_just_pressed("shoot"):
		throw_shuriken()
	
func throw_shuriken() -> void:
	var shuriken = SHURIKEN_SCENE.instantiate()
	shuriken.global_position = global_position
	# aims toward the mouse
	shuriken.direction = global_position.direction_to(get_global_mouse_position())
	get_parent().add_child(shuriken)
	
func take_damage(amount: int) -> void:
	health = clampi(health - amount, 0, MAX_HEALTH)
	
	animated_sprite_2d.modulate = Color(1, 0.5, 0.5)
	create_tween().tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.15)
	
	
	if health_bar:
		var tween = create_tween()
		tween.tween_property(health_bar, "value", health, 0.2)
		
	if health <= 0:
		die()
	
func die() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/UI/game_over_screen.tscn")
