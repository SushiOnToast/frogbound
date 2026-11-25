extends Control

@onready var score_label: Label = $ScoreLabel

func _ready() -> void:
	score_label.text = "Score: " + str(Game.score)
	
	$HighScoreLabel.text = "Best: " + str(Game.high_score)
	if Game.is_new_high_score:
		$HighScoreLabel.text += " — NEW BEST!"

func _input(_event):
	if Input.is_action_just_pressed("menu_interact"):
		start_game()

func start_game():		
		Game.start_game()
