extends Control


@onready var resume_button: Button = $VBox/ResumeButton


func _ready() -> void:
	resume_button.grab_focus()
	$VBox/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBox/RestartButton.pressed.connect(_on_restart_pressed)
	$VBox/MenuButton.pressed.connect(_on_menu_pressed)


func _on_resume_pressed() -> void:
	Sfx.play_click()
	Game.resume_game()


func _on_restart_pressed() -> void:
	Sfx.play_click()
	Game.start_game()


func _on_menu_pressed() -> void:
	Sfx.play_click()
	Game.to_menu()
