extends Area2D

@export var direction: Vector2
var target: Node2D

const SPEED = 175
const TURN_RATE = 1.2 # rad per s
const HOMING_TIME = 1.2 # s before it stops turning

var age:= 0.0

func _ready() -> void:
	add_to_group("projectile")

func _process(delta: float) -> void:
	age += delta
	
	if is_instance_valid(target) and age < HOMING_TIME:
		var desired := (target.global_position - global_position).normalized()
		var angle := direction.angle_to(desired)
		var max_turn := TURN_RATE * delta
		direction = direction.rotated(clampf(angle, -max_turn, max_turn))
	
	position += direction * SPEED * delta
	rotation = direction.angle() 
	
	# delete if it goes out of bounds; prevent lag
	if position.x < -560 or position.x > 656 or position.y < -464 or position.y > 656:
		queue_free()
		

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(10)
		queue_free()
