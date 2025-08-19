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
@export var dash_curve : Curve

var able_to_jump = true
var able_to_dash = true
var is_dashing = false
var is_jumping = false
var dash_start_position : Vector2
var dash_direction : Vector2 = Vector2.ZERO
var last_direction : Vector2 = Vector2.RIGHT

# For camera
func _ready():
	add_to_group("player")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		able_to_jump = false
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and able_to_jump:
		velocity.y = jump_velocity
		is_dashing = false
		is_jumping = true
	if not Input.is_action_pressed("Jump") and velocity.y < 0 and not is_dashing:
		velocity.y *=decelerate_on_jump_release
	
	
	# Get input direction as Vector2
	var input_direction = Vector2(
		Input.get_axis("Left","Right"),
		Input.get_axis("Up","Down")
	).normalized()
	
	if input_direction != Vector2.ZERO :
		last_direction = input_direction
	
	
	# Normal movement (only if not dashing)
	if is_on_floor():
		if not is_dashing:
			velocity.x = move_toward(velocity.x, input_direction.x * speed, speed * acceleration)
			if input_direction.x == 0:
				velocity.x = move_toward(velocity.x, 0, speed * deceleration)
	else:
		if not is_dashing:
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
