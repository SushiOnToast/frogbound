extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const SPEED = 150
var perm_direction: Vector2
var animation: String = "idle"

static func movement_input() -> Vector2:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
		
	return direction
	

func animate_sprite(animation: String, direction: Vector2) -> void:
	if direction == Vector2.UP:
		animated_sprite_2d.play("%s_%s" % [animation, "up"])
	elif direction == Vector2.DOWN:
		animated_sprite_2d.play("%s_%s" % [animation, "down"])
	elif direction == Vector2.LEFT:
		animated_sprite_2d.play("%s_%s" % [animation, "left"])
	elif direction == Vector2.RIGHT:
		animated_sprite_2d.play("%s_%s" % [animation, "right"])
	

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
