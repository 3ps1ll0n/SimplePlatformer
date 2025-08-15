extends CharacterBody2D
#  List des variables

@export var SPEED = 300.0
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var deceleration = 0.1

@export var JUMP_VELOCITY = -400.0
@export_range(0,1) var decelerate_on_jump_release = 0.5


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if not Input.is_action_pressed("Jump") and velocity.y < 0:
		velocity.y *=decelerate_on_jump_release
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("Move Left", "Move Right")
	
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * deceleration)
	
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
