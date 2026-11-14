extends Area2D

@export var direction: Vector2

const SPEED = 175

func _ready() -> void:
	add_to_group("projectile")

func _process(delta: float) -> void:
	position += direction * SPEED * delta
	
	if position.x < -560 or position.x > 656 or position.y < -464 or position.y > 656:
		queue_free()
		

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("hit")
