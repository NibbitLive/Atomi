extends Node

var playerbody: CharacterBody2D
var playerDamageAmount: int
var playerDamageZone: Area2D
var playerAlive: bool

var enemyDamageZone: Area2D
var enemyDamageAmount: int

# Dictionary to store item scenes for different enemy types
var enemy_item_drops: Dictionary = {}

# Method to register item drops for an enemy type
func register_enemy_item_drop(enemy_type: String, item_scene_path: String) -> void:
	enemy_item_drops[enemy_type] = preload("res://item.tscn")

# Method to get the item scene for a specific enemy type
func get_item_scene_for_enemy(enemy_type: String) -> PackedScene:
	return enemy_item_drops.get(enemy_type, null)

func _ready():
	# Register item drops for different enemy types
	register_enemy_item_drop("enemy_temp", "res://item.tscn")
