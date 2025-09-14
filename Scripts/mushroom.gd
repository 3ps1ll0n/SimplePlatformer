extends "res://Scripts/enemy_class.gd"

const JUMP_VELOCITY = -400.0
var state : AI_State = AI_State.IDLE
var attack_count = 0

@export var hunting_distance := 400
@export var attack_distance := 45
@export var speed = 100.0

@onready var player: CharacterBody2D = %Player
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

enum AI_State{
	IDLE,
	HUNTING,
	ATTACKING,
	STUNNED,
	DEAD
}

var direction := 0

func _ready() -> void:
	max_health = 15
	current_health = max_health
	super._ready()

func _physics_process(delta: float) -> void:
	if state == AI_State.DEAD:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if dead:
		state = AI_State.DEAD
		animated_sprite.play("Death")
		return
	
	var distance_from_player := position.distance_to(player.position)
	
	if state == AI_State.ATTACKING:
		super._physics_process(delta)
		move_and_slide()
	
		return
	
	if distance_from_player < attack_distance:
		state = AI_State.ATTACKING
	elif  distance_from_player < hunting_distance:
		state = AI_State.HUNTING
	else:
		state = AI_State.IDLE
	
	if state == AI_State.HUNTING:
		hunt()
		velocity.x = move_toward(velocity.x, direction * speed, speed)
	elif state == AI_State.ATTACKING:
		hunt()
		attack()
		
	super._physics_process(delta)
	
	#========================================== Animation Section ==========================================
	
	animated_sprite.flip_h = direction > 0

	if state == AI_State.HUNTING:
		animated_sprite.play("Run")
	elif state == AI_State.ATTACKING:
		if attack_count < 2:
			animated_sprite.play("Attack")
		else:
			animated_sprite.play("Attack_Stunned")
	else:
		animated_sprite.play("Idle")

	move_and_slide()
	
	
	
func hunt():
	if position.x > player.position.x:
		direction = -1
	else:
		direction = 1

func attack():
	velocity = Vector2.ZERO
	var offset = 20.0
	var attack_point := Vector2.ZERO
	attack_point.x = direction * offset
	attack_point.y = -10
	#attack_point.rotation = dir.angle()
	await get_tree().create_timer(0.5).timeout
	# Instancie la hitbox
	var hitbox = preload("res://Scenes/Attack_Hit_Box.tscn").instantiate()
	add_child(hitbox)
	hitbox.position = attack_point
	
	hitbox.set_shape(RectangleShape2D.new() , Vector2(15, 15))
	
	# Supprime après la durée
	await get_tree().create_timer(0.5).timeout
	hitbox.queue_free()
	attack_count += 1

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "Attack":
		state = AI_State.IDLE
	elif animated_sprite.animation == "Attack_Stunned":
		state = AI_State.IDLE
		attack_count = 0
