extends CharacterBody2D
class_name EnemyTemp

const speed = 30
const gravity = 1000
const knockback_duration = 0.2
const knockback_force = -500
const knockback_y_bounce = -300

var is_enemy_chase: bool
var health = 80
var maxHealth = 80
var minHealth = 0
var dead: bool = false
var taking_damage: bool = false
var damage_to_deal = 20
var is_dealing_damage: bool = false

var dir: Vector2
var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area: bool = false

var knockback_timer = 0.0
var knockback_velocity = Vector2.ZERO

var enemy_type: String = "enemy_temp"

func _process(delta):
	if knockback_timer > 0:
		knockback_timer -= delta
		if knockback_timer <= 0:
			taking_damage = false
			velocity.x = 0
			if is_on_floor():
				is_enemy_chase = true
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.x = 0

		if Global.playerAlive:
			is_enemy_chase = true
		else:
			is_enemy_chase = false

		Global.enemyDamageAmount = damage_to_deal
		Global.enemyDamageZone = $enemyDealDamageArea
		player = Global.playerbody

		move(delta)
		move_and_slide()

func move(delta):
	if !dead:
		if !is_enemy_chase:
			velocity += dir * speed * delta
		elif is_enemy_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			if knockback_timer <= 0:
				velocity = knockback_velocity
				velocity.y = knockback_y_bounce
				knockback_timer = knockback_duration
				is_enemy_chase = false
		is_roaming = true
	elif dead:
		velocity.x = 0

func take_damage(damage):
	if Global.playerDamageAmount > 0:
		health -= damage
		taking_damage = true
		if health <= minHealth:
			health = minHealth
			dead = true
			_drop_item()  # Drop the item when the enemy dies
			queue_free()
		print(str(self), "Current health is ", health)
		apply_knockback()

func apply_knockback():
	var knockback_direction = (position - player.position).normalized()
	knockback_velocity = knockback_direction * knockback_force
	velocity = knockback_velocity
	knockback_timer = knockback_duration

func _drop_item():
	var item_scene = Global.get_item_scene_for_enemy(enemy_type)
	if item_scene:
		var item_instance = item_scene.instantiate()
		item_instance.position = position  # Position the item at the enemy's location
		get_parent().add_child(item_instance)  # Add the item to the scene tree
