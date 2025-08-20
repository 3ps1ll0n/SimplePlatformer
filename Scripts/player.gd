extends CharacterBody2D
#  List des variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var grappling: Node2D = $"../Grappling"

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
var dash_start_position : Vector2
var dash_direction : Vector2 = Vector2.ZERO

var last_direction : Vector2 = Vector2.RIGHT
# For camera
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
	
	# Get input direction as Vector2
	var input_direction = Vector2(
		Input.get_axis("Left","Right"),
		Input.get_axis("Up","Down")
	).normalized()
	
	if input_direction != Vector2.ZERO :
		last_direction = input_direction
	
	
	# Normal movement (only if not dashing)
	if not is_dashing:
		velocity.x = move_toward(velocity.x, input_direction.x * speed, speed * acceleration)
		#velocity.y = move_toward(velocity.y, input_direction.y * speed if input_direction.y != 0 else velocity.y, speed * acceleration)
		if input_direction.x == 0:
			velocity.x = move_toward(velocity.x, 0, speed * deceleration)
		
	# Dash activation
	if Input.is_action_just_pressed("Dash") and not is_dashing and able_to_dash:
		is_dashing = true
		able_to_dash = false
		dash_start_position = position
		if input_direction != Vector2.ZERO:
			dash_direction = input_direction
		else:
			dash_direction = last_direction
		dash_direction = dash_direction.normalized()
	if Input.is_action_just_pressed("Grappling_Hook"):
		var mouse_pos = get_global_mouse_position()
		grappling.fire(self, mouse_pos)
		
	if is_on_floor():
		able_to_dash = true
	
	# Performe actual dash.
	if is_dashing:
		var current_distance = position.distance_to(dash_start_position)
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity = dash_direction * dash_speed * dash_curve.sample(current_distance/dash_max_distance)
	
	
	
	
	
	
	
	
	#========================================== Animation Section ==========================================
	
	#if input_direction > 0:
	#	animated_sprite.flip_h = false
	#elif input_direction < 0:
	#	animated_sprite.flip_h = true
	
	#if is_dashing = true:
		#animated_sprite.play("Run")
	#else:
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
