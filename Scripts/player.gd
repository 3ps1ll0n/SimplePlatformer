extends CharacterBody2D
#  List des variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed = 200.0
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var deceleration = 0.1

@export var jump_velocity = -400.0
@export_range(0,1) var decelerate_on_jump_release = 0.5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var dash_speed = 500
@export var dash_max_distance = 90
@export var dash_curve : Curve

var able_to_dash = true
var is_dashing = false
var dash_start_position = 0
var dash_direction = 0

var last_direction = 1

func _ready():
	add_to_group("player")

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
	
	if direction != 0 :
		last_direction = direction
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)
	
	# Dash activation
	if Input.is_action_just_pressed("Dash") and not is_dashing and able_to_dash:
		is_dashing = true
		able_to_dash = false
		dash_start_position = position.x
		# use current input direction, otherwise fallback to last direction
		if direction != 0:
			dash_direction = direction 
		else:
			dash_direction = last_direction 
	if is_on_floor():
		able_to_dash = true
	
	# Performe actual dash.
	if is_dashing:
		var current_distance = abs(position.x - dash_start_position)
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance/dash_max_distance)
			velocity.y = 0
	
	
	
	
	
	
	
	
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
