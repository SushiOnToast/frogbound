extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const SPEED = 150
var perm_direction: Vector2
var animation: String = "idle"

func _ready() -> void:
	add_to_group("player")

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
	

func _physics_process(delta: float) -> void:
	var direction: Vector2 = movement_input()
		
	if direction != Vector2.ZERO:
		perm_direction = direction
		animation = "walk"
	else:
		animation = "idle"
	
	animate_sprite(animation, perm_direction)
	
	velocity = direction * SPEED
	move_and_slide()
