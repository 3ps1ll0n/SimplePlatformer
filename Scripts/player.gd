extends CharacterBody2D
#  List des variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed = 300.0
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var deceleration = 0.1

@export var jump_velocity = -400.0
@export_range(0,1) var decelerate_on_jump_release = 0.5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var dash_speed = 300
@export var dash_max_distance = 90
@export var dash_curve = "res://Scenes/Player.tscn::Curve_52ee3"
@export var dash_cooldown = 0.5

var is_dashing = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if not Input.is_action_pressed("Jump") and velocity.y < 0:
		velocity.y *=decelerate_on_jump_release
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("Move Left", "Move Right")
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)
	
	# Dash activation
	if Input.is_action_just_pressed("Dash") and direction and not is_dashing and dash_timer <= 0:
		is_dashing = true
		dash_start_position = position.x
		dash_direction = direction
		dash_timer = dash_cooldown
	
	# Performe actual dash.
	if is_dashing:
		var current_distance = abs(position.x - dash_start_position)
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance/dash_max_distance)
			velocity.y = 0
	
	# Reduce the dash timer.
	if dash_timer > 0:
		dash_timer -= delta
	
	
	
	
	
	
	
	
	
	
	#========================================== Animation Section ==========================================
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
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
