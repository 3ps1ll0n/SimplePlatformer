extends CharacterBody2D
#  List des variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var grappling_hook: Node2D = $"../Grappling_Hook"

@export var speed = 200.0
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var momentum = 0.1

@export var jump_velocity = -400.0
@export_range(0,1) var decelerate_on_jump_release = 0.5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var dash_speed = 500
@export var dash_curve : Curve


@export var attack_cooldown := 0.3   # temps entre deux attaques
@export var attack_duration := 0.15  # durée pendant laquelle la hitbox est active
@onready var attack_point = $AttackPoint

var able_to_jump = true
var able_to_dash = true
var is_dashing = false
var is_jumping = false
var can_attack := true
var dash_start_position : Vector2
var dash_direction : Vector2 = Vector2.ZERO
var last_direction : Vector2 = Vector2.RIGHT
var attack_direction := Vector2.RIGHT 

# For camera
func _ready():
	add_to_group("player")

func _physics_process(delta):
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
	if Input.is_action_just_pressed("Dash") and not is_dashing and able_to_dash:
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
			
	if Input.is_action_just_pressed("Grapple"):
		grappling_hook.fire(self, get_global_mouse_position())
	elif Input.is_action_just_released("Grapple"):
		grappling_hook.reset()
	
	if Input.is_action_just_pressed("Attack") and can_attack:
		perform_attack()
	
	
	
	
	
	#========================================== Animation Section ==========================================
	
	if input_direction > Vector2.ZERO:
		animated_sprite.flip_h = false
	elif input_direction < Vector2.ZERO:
		animated_sprite.flip_h = true
	
	if is_dashing == true:
		animated_sprite.play("Double_Jump")
	else:
		if not is_on_floor():
			if velocity.y < 0:
				animated_sprite.play("Jump")
			elif velocity.y > 0:
				animated_sprite.play("Fall")
		else:
			if velocity.x != 0:
				animated_sprite.play("Run")
			else:
				animated_sprite.play("Idle")
	

	move_and_slide()
	
func perform_attack() -> void:
	can_attack = false
	var dir := get_attack_direction()
	# Place le AttackPoint selon la direction
	var offset = 32.0 # distance devant le joueur
	attack_point.position = dir * offset
	#attack_point.rotation = dir.angle()
	
	# Instancie la hitbox
	var hitbox = preload("res://Scenes/Attack_Hit_Box.tscn").instantiate()
	attack_point.add_child(hitbox)
	
	# Donne la même rotation à la hitbox (utile si rectangulaire)
	hitbox.rotation = dir.angle()
	hitbox.set_collision_mask_value(2, true)
	
	hitbox.set_shape(RectangleShape2D.new(), Vector2(40, 10))
	
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
