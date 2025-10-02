extends CharacterBody2D
#  List des variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var grappling_hook: Node2D = $"../Grappling_Hook"
@onready var fight_animation: AnimationPlayer = $FightAnimation
@onready var spell_manager: Node2D = $Spell_Manager

@export var speed = 200.0
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var momentum = 0.1

@export var jump_velocity = -400.0
@export_range(0,1) var decelerate_on_jump_release = 0.5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var dash_speed = 500
@export var dash_curve : Curve

@export var attack_cooldown := 0.30   # temps entre deux attaques
@export var attack_duration := 0.10  # durée pendant laquelle la hitbox est active
@onready var attack_point = $AttackPoint
var attack_point_offset = 15.0
#Value for knockback handling
@export var knockback_strength: float = 250.0
var knockback_velocity: Vector2 = Vector2.ZERO
#Value for health handling
@export var max_health = 40
var current_health = max_health
var is_dead = false

const TEAM_ENUM = preload("res://Scripts/attack_hit_box.gd")

var able_to_jump = true
var able_to_dash = true
var unlock_dash = false
var unlock_grapple = false
var is_dashing = false
var is_jumping = false
var can_attack := true
var is_invincible := false
var dash_start_position : Vector2
var dash_direction : Vector2 = Vector2.ZERO
var last_direction : Vector2 = Vector2.RIGHT
var attack_direction := Vector2.RIGHT 

var play_locked = false
var movement_locked = false

# For camera
func _ready():
	add_to_group("player")
	$CentralPoint.add_to_group("player")

func _physics_process(delta):

	if is_dead:
		return

	# Add the gravity.
	if not is_on_floor() and not grappling_hook.get_is_hooked():
		able_to_jump = false
		velocity.y += gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("Jump"):
		$JumpBufferTimer.start()
		
	if able_to_jump and not is_dashing and $"JumpBufferTimer".time_left > 0 and not grappling_hook.get_is_hooked():
		velocity.y = move_toward(velocity.y, jump_velocity, speed * 100 )
		is_dashing = false
		is_jumping = true
	if not Input.is_action_pressed("Jump") and velocity.y < 0 and not is_dashing and $"JumpBufferTimer".time_left > 0 and not grappling_hook.get_is_hooked():
		velocity.y *=decelerate_on_jump_release
	
	
	# Get input direction as Vector2
	var input_direction = Vector2(
		Input.get_axis("Left","Right"),
		Input.get_axis("Up","Down")
	).normalized()
	
	if input_direction != Vector2.ZERO :
		last_direction = input_direction
	
	
	# Normal movement (only if not dashing)

	if is_on_floor() and not is_dashing:
		velocity.x = move_toward(velocity.x, input_direction.x * speed, speed * acceleration)
	else: 
		if input_direction.x != velocity.x/abs(velocity.x):
			velocity.x = move_toward(velocity.x, input_direction.x * speed, speed * momentum)
		
		if abs(velocity.x) < abs(input_direction.x) * speed:
			velocity.x = move_toward(velocity.x, input_direction.x * speed, speed)
	
	# Dash activation
	if Input.is_action_just_pressed("Dash") and not is_dashing and able_to_dash and unlock_dash:
		is_dashing = true
		able_to_dash = false
		is_jumping = false
		dash_start_position = position
		if input_direction != Vector2.ZERO:
			dash_direction = input_direction
		else:
			dash_direction = last_direction
		dash_direction = dash_direction.normalized()

		$"Dash Timer".start()
		
	if not is_dashing and is_on_floor():
		able_to_dash = true
		able_to_jump = true
	# Performe actual dash.
	if is_dashing:
		
		var current_distance = position.distance_to(dash_start_position)
		velocity = dash_direction * dash_speed * dash_curve.sample(current_distance)
		if $"Dash Timer".time_left <= 0 :
			is_dashing = false
			
	if Input.is_action_just_pressed("Grapple") and unlock_grapple:
		grappling_hook.fire(self, get_global_mouse_position())
	elif Input.is_action_just_released("Grapple"):
		grappling_hook.reset()
	
	if Input.is_action_just_pressed("Attack") and can_attack:
		perform_attack()
	elif Input.is_action_just_pressed("Cast_Spell"):
		var dir := get_attack_direction()
		attack_point.position = dir * attack_point_offset
		fight_animation.play("Slash_Spell")
	
	if knockback_velocity != Vector2.ZERO:
		# Apply knockback decay over time
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 2000 * delta)
		velocity = knockback_velocity
	
	
	
	#========================================== Animation Section ==========================================
	if !play_locked:
		if input_direction.x > 0:
			animated_sprite.flip_h = false
		elif input_direction.x < 0:
			animated_sprite.flip_h = true
		
		if is_dashing == true:
			set_animation("Double_Jump")
		else:
			if not is_on_floor():
				if velocity.y < 0:
					set_animation("Jump")
				elif velocity.y > 0:
					set_animation("Fall")
			else:
				if velocity.x != 0:
					set_animation("Run")
				else:
					set_animation("Idle")
	

	if not movement_locked:
		move_and_slide()
	
func _unlock_dash():
	unlock_dash = true
func _unlock_grapple():
	unlock_grapple = true
func perform_attack() -> void:
	can_attack = false
	play_locked = true
	var dir := get_attack_direction()
	if dir == Vector2.UP:
		set_animation("Attack_Up")
	else:
		set_animation("Attack")
	# Place le AttackPoint selon la direction
	attack_point.position = dir * attack_point_offset
	#attack_point.rotation = dir.angle()
	
	# Instancie la hitbox
	var hitbox = preload("res://Scenes/Attack_Hit_Box.tscn").instantiate()
	attack_point.add_child(hitbox)
	
	# Donne la même rotation à la hitbox (utile si rectangulaire)
	hitbox.rotation = dir.angle() + PI/2
	hitbox.set_collision_mask_value(2, true)
	
	hitbox.set_properties(5, TEAM_ENUM.TEAM.PLAYER, CapsuleShape2D.new(), Vector2(10, 30))
	hitbox.add_to_group("player_attack")
	
	# Supprime après la durée
	await get_tree().create_timer(attack_duration).timeout
	hitbox.queue_free()
	
	# Cooldown avant prochaine attaque
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
func get_attack_direction() -> Vector2:
	var dir = Vector2.ZERO
	if Input.is_action_pressed("Up"):
		dir = Vector2.UP
	elif Input.is_action_pressed("Down"):
		dir = Vector2.DOWN
	elif Input.is_action_pressed("Left"):
		dir = Vector2.LEFT
	elif Input.is_action_pressed("Right" ):
		dir = Vector2.RIGHT
	else:
		dir = last_direction # défaut = attaque horizontale droite
	return dir


func _on_jump_buffer_timer_timeout() -> void:
	pass # Replace with function body.

func take_damage(damage: int) -> void:
	if is_invincible or is_dead:
		return
	current_health -= damage
	fight_animation.play("Blink")
	set_animation("Hitted")
	play_locked = true
	
	if current_health <= 0:
		is_dead = true
		set_animation("Death")
		#die()

func take_knockback(from_position : Vector2):
	if is_invincible:
		return
		
	var direction = sign(position.x - from_position.x) # +1 if hit from left, -1 if hit from right
	knockback_velocity.x = direction * knockback_strength
	# optionally add some Y if you want a pop-up effect
	knockback_velocity.y = -100
	
func push_player(force : Vector2):
	velocity = force

func trigger_invincibility():
	is_invincible = true
	
func get_is_invincible():
	return is_invincible

func get_max_health():
	return max_health
	
func get_current_health():
	return current_health

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "Attack" or animated_sprite.animation == "Attack_Up" or animated_sprite.animation == "Hitted":
		play_locked = false

		
func set_animation(animation_name : String) -> void:
	if animation_name == "Attack_Up":
		animated_sprite.offset = Vector2(0, -10)
	elif animation_name == "Jump" or animation_name == "Fall":
		animated_sprite.offset = Vector2(0, -16)
	elif animation_name == "Double_Jump":
		animated_sprite.offset = Vector2(0, -7)
	elif animation_name == "Hitted":
		animated_sprite.offset = Vector2(0, -8)
	else:
		animated_sprite.offset = Vector2.ZERO
	
	animated_sprite.play(animation_name)
	pass	

func _on_fight_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Blink":
		is_invincible = false;

func lock_animation():
	play_locked = true

func unlock_animation():
	play_locked = false
	
func lock_movement():
	movement_locked = true

func unlock_movement():
	movement_locked = false
	velocity.y = 0
