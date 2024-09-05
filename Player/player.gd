extends CharacterBody2D
class_name Player

const NORMAL_SPEED = 300.0
const JUMP_VELOCITY = -250.0
const DASH_HORIZONTAL_SPEED = 600.0
const DASH_VERTICAL_SPEED = 300.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1.0
const ATTACK_HITBOX_DURATION = 0.2  # Duration the hitbox remains visible

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_indicator: ColorRect = $"../UI/DashIndicatorTemp"
@onready var camera: Camera2D = $Camera2D
@onready var deal_damage_zone = $DealDamageZone
@onready var attack_timer: Timer = $AttackTimer  # Ensure this matches the Timer node's name
@onready var mana_bar: TextureProgressBar = $"../UI/ManaBar" # Add the Mana Bar
 

# Heart health system variables
@onready var hearts = [
	$"../UI/Heart1",
	$"../UI/Heart2",
	$"../UI/Heart3",
	$"../UI/Heart4",
	$"../UI/Heart5"
]



var full_heart_texture: Texture = preload("res://full_heart.png")
var empty_heart_texture: Texture = preload("res://empty_heart.png")



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dashing = false
var dash_time_left = 0.0
var dash_cooldown_left = 0.0
var squish: Vector2 = Vector2(1, 1)
var dashStartPos: Vector2
var dashEffectCount = 3
var characterDirection: int = 1
var attack_type: String
var current_attack: bool
var dir: int
var death_screen = preload("res://death_screen.tscn")

# Health variables
var max_health = 5
var current_health = 5
var damage_cooldown = 0.0  # Cooldown timer for taking damage
const DAMAGE_COOLDOWN_TIME = 1.0  # 1 second of invulnerability after taking damage

# Mana variables
var max_mana = 100  # Set the maximum mana value
var current_mana = 0  # Initialize the current mana value

func _ready() -> void:
	Global.playerbody = self
	current_attack = false
	Global.playerDamageZone = deal_damage_zone
	Global.playerAlive = true
	
	# Add the player's damage zone to the group "PlayerAttackZone"
	deal_damage_zone.add_to_group("PlayerAttackZone")
	
	_update_dash_indicator()
	_update_hearts()
	_update_mana_bar()  # Update the mana bar UI
	


func _physics_process(delta: float) -> void:
	# Apply gravity when not dashing
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta
	
	# Update dash cooldown
	if dash_cooldown_left > 0:
		dash_cooldown_left -= delta

	# Update damage cooldown
	if damage_cooldown > 0:
		damage_cooldown -= delta
	
	# Handle jump (continuous jumping when holding jump button)
	if Input.is_action_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
	
	# Handle dashing
	if Input.is_action_just_pressed("dash") and dash_cooldown_left <= 0:
		var dash_direction = Vector2.ZERO
		
		# Determine dash direction
		if Input.is_action_pressed("up"):
			dash_direction.y = -1
		elif Input.is_action_pressed("down"):
			dash_direction.y = 1
		
		if Input.is_action_pressed("left"):
			dash_direction.x = -1
		elif Input.is_action_pressed("right"):
			dash_direction.x = 1
		
		if dash_direction != Vector2.ZERO:
			is_dashing = true
			dash_time_left = DASH_DURATION
			dash_cooldown_left = DASH_COOLDOWN
			dash_direction = dash_direction.normalized()

			velocity.x = dash_direction.x * DASH_HORIZONTAL_SPEED
			velocity.y = dash_direction.y * DASH_VERTICAL_SPEED
			
			dashStartPos = global_position
			dashEffectCount = 3
			squish.x = 1.4
			squish.y = 0.4
			
			#_trigger_particle_burst(global_position)
			camera.shake(4.0, 0.1)
	
	# Update dash timer
	if is_dashing:
		dash_time_left -= delta
		if dash_time_left <= 0:
			is_dashing = false
	
	# Handle normal movement if not dashing
	if not is_dashing:
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * NORMAL_SPEED
			toggle_flip_sprite(direction)
		else:
			velocity.x = move_toward(velocity.x, 0, NORMAL_SPEED)
	
	if !current_attack:
		if Input.is_action_just_pressed("attack"):
			current_attack = true
			_attack()
		
	_update_dash_indicator()
	move_and_slide()
	check_hitbox()

func _update_dash_indicator() -> void:
	if dash_cooldown_left > 0:
		dash_indicator.color = Color(1, 0, 0, 0.5)
	else:
		dash_indicator.color = Color(0, 1, 0, 0.5)

func _update_hearts() -> void:
	for i in range(max_health):
		if i < current_health:
			hearts[i].texture = full_heart_texture
		else:
			hearts[i].texture = empty_heart_texture

func _update_mana_bar() -> void:
	mana_bar.value = current_mana  # Update the mana bar's value

func check_hitbox() -> void:
	var hitbox_areas = $PlayerHitBox.get_overlapping_areas()
	for area in hitbox_areas:
		if area.get_parent() is EnemyTemp:
			take_damage(1)  # Take 1 heart of damage
			break

func take_damage(amount: int) -> void:
	if damage_cooldown <= 0:  # Only take damage if not in cooldown
		current_health = max(current_health - amount, 0)
		_update_hearts()
		damage_cooldown = DAMAGE_COOLDOWN_TIME  # Start cooldown after taking damage
		
		# Check if the first heart has changed to the empty heart texture
		if hearts[0].texture == empty_heart_texture:
			Global.playerAlive = false
			show_death_screen()  # Show the death screen when the player dies
			queue_free()  # Remove the player from the scene

func show_death_screen() -> void:
	var death_screen_instance = death_screen.instantiate()
	get_tree().current_scene.add_child(death_screen_instance)

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	_update_hearts()

#func _trigger_particle_burst(position: Vector2) -> void:
	#dash_particles.position = position
	#dash_particles.emitting = true
	#await get_tree().create_timer(0.2).timeout
	#dash_particles.emitting = false

func _attack() -> void:
	Global.playerDamageAmount = 10  # Set the damage amount when attacking
	deal_damage_zone.show()  # Make the attack hitbox visible
	if attack_timer:
		attack_timer.wait_time = ATTACK_HITBOX_DURATION  # Set the duration the hitbox is visible
		attack_timer.start()  # Start the timer to hide the hitbox after a delay
	for body in deal_damage_zone.get_overlapping_bodies():
		if body.is_in_group("enemies"):  # checks if enemies are in a group called "enemies"
			body.take_damage(Global.playerDamageAmount)  # Trigger the damage function on the enemy
			_increase_mana()  # Increase mana when hitting an enemy
	current_attack = false

func _increase_mana() -> void:
	current_mana = min(current_mana + 1, max_mana)  # Increase mana by 1, without exceeding max_mana
	_update_mana_bar()

func _on_attack_timer_timeout() -> void:
	deal_damage_zone.hide()  # Hide the attack hitbox when the timer times out

func toggle_flip_sprite(dir):
	if dir == 1:
		deal_damage_zone.scale.x = 1
	if dir == -1:
		deal_damage_zone.scale.x = -1
