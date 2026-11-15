extends CanvasLayer

@onready var wave_label: Label = $"Wave Label"
@onready var score_label: Label = $"Score Label"

func _process(delta: float) -> void:
	wave_label.text = "Wave " + str(Game.wave)
	score_label.text = str(Game.score) + " pts"
