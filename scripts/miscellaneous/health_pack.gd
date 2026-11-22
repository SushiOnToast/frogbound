extends Area2D

const HEAL_AMOUNT := 25
const LIFETIME := 20.0

@onready var sprite: Sprite2D = $Sprite2D

var _age := 0.0
var _base_y := 0.0


func _ready() -> void:
	add_to_group("pickup")
	_base_y = sprite.position.y


func _process(delta: float) -> void:
	_age += delta
	# Gentle bob so it reads as a pickup item and not floor decoration
	sprite.position.y = _base_y + sin(_age * 3.0) * 2.0
	if _age > LIFETIME - 3.0:
		# Blink in the last seconds before it disappears.
		sprite.visible = int(_age * 6.0) % 2 == 0
	if _age >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if not body.has_method("heal"):
		return
	if body.health >= body.MAX_HEALTH:
		return
	body.heal(HEAL_AMOUNT)
	queue_free()
