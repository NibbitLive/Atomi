extends Node2D

var paused = false
var death = false

@onready var pause_menu = $UI/PauseMenu
@onready var death_screen = $UI/DeathScreen
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	
	
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	
	paused = !paused
