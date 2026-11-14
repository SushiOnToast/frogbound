extends Area2D

var direction: Vector2
const SPEED = 350
const DAMAGE = 15

func _ready() -> void:
	add_to_group("projectile")

func _process(delta: float) -> void:
	position += direction * SPEED * delta
	# Spins the shuriken while flying
	rotation += 15.0 * delta 
	
	# Same out-of-bounds cleanup as octopus_projectile.gd
	if position.x < -560 or position.x > 656 or position.y < -464 or position.y > 656:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(DAMAGE)
		queue_free()
