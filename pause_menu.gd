extends Control

@onready var map = $"../../"

func _on_resume_pressed():
	Global.playerAlive = true
	map.pauseMenu()
	get_tree().reload_current_scene()


func _on_quit_pressed():
	get_tree().quit()
