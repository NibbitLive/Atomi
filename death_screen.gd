extends Control

@onready var map = $"../../"

func _ready() -> void:
	center_death_screen()

func center_death_screen() -> void:
	# Get the viewport size
	var viewport_size = get_viewport_rect().size

	# Set the position of the death screen to be centered
	var new_position = (viewport_size - self.size) / 2
	self.position = new_position

func _on_resume_pressed():
	Global.playerAlive = true
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
