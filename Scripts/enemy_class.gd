extends CharacterBody2D

@onready var flash_animation: AnimationPlayer = $AnimatedSprite2D/FlashAnimation

@export var max_health := 100
@export var knockback_strength: float = 200.0

var current_health := max_health
var knockback_velocity: Vector2 = Vector2.ZERO

var dead := false

func _ready() -> void:
	add_to_group("enemies")

func take_damage(damage: int) -> void:
	if dead:
		return
	current_health -= damage
	flash_animation.play("flash")
	if current_health <= 0:
		die()

func take_knockback(from_position : Vector2):
	var direction = sign(global_position.x - from_position.x) # +1 if hit from left, -1 if hit from right
	knockback_velocity.x = direction * knockback_strength
	# optionally add some Y if you want a pop-up effect
	knockback_velocity.y = -100

func die() -> void:
	dead = true
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	#queue_free()

func _physics_process(delta: float) -> void:
	if knockback_velocity == Vector2.ZERO:
		return
	# Apply knockback decay over time
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 2000 * delta)

	velocity.x = knockback_velocity.x
	#velocity.y += 800 * delta # gravity, if needed
	
func is_dead() -> bool:
	return dead
