extends "res://Scripts/enemy_class.gd"

const SPEED = 100.0

@export var search_range = 80
@export var detection_range = 100 
@export var attack_range = 30
@export var max_waiting_time := Vector2(0.5, 2)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wait_idle_time: Timer = $WaitIdleTime
@onready var player: CharacterBody2D = %Player

var wandering_point := Vector2.ZERO #Point the bee will randomly move arround
var search_point := Vector2.ZERO #Random point the bee will go to

var state : AI_State = AI_State.IDLE

enum AI_State{
	IDLE,
	WANDER,
	HUNTING,
	ATTACKING,
	DEAD
}
func _ready() -> void:
	wandering_point = position
	new_search_point()
	
	max_health = 10
	current_health = max_health
	
	set_random_wait_time()
	
func _physics_process(delta: float) -> void:
	
	var distance_from_player = position.distance_to(player.position)
	
	if distance_from_player < attack_range:
		AI_State.ATTACKING
	if state != AI_State.HUNTING && distance_from_player < detection_range:
		state = AI_State.HUNTING
	
		
	
	if state == AI_State.IDLE:
		return
	elif state == AI_State.WANDER:
		if position.distance_to(search_point) > 10:
			var dir := search_point - position
			velocity = dir.normalized() * SPEED
		else:
			set_random_wait_time()
			state = AI_State.IDLE
		pass
	elif state == AI_State.HUNTING:
		var dir := player.position - position
		velocity = dir.normalized() * SPEED
		if distance_from_player > detection_range:
			state = AI_State.IDLE
			wandering_point = position
			
	#========================================== Animation Section ==========================================
	
	if velocity.x < 0:
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.flip_h = false
	
	if state == AI_State.IDLE:
		animated_sprite.play("Idle")
	elif state == AI_State.WANDER || state == AI_State.HUNTING:
		animated_sprite.play("Walk")
	elif state == AI_State.ATTACKING:
		animated_sprite.play("Attack")

	move_and_slide()

func new_search_point():
	search_point = wandering_point + Vector2(randi() % search_range * [1, -1].pick_random(), randi() % search_range * [1, -1].pick_random())

func set_random_wait_time():
	wait_idle_time.wait_time = randf() * (max_waiting_time.y - max_waiting_time.x) + max_waiting_time.x
	wait_idle_time.start()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "Attack":
		state = AI_State.IDLE

func _on_wait_idle_time_timeout() -> void:
	state = AI_State.WANDER
	new_search_point()
