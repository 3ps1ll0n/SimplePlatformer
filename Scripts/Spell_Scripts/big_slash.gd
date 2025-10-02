extends Area2D

var travelling_distance = 200
var travelling_speed = 400
var origin_point = Vector2(0, 0)

var direction = 1
var can_move := false

@onready var timer: Timer = $Timer
@onready var slash_attack_hb: Area2D = $SlashAttackHB
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slash_projectile_hb: Area2D = $SlashProjectileHB

const TEAM_ENUM = preload("res://Scripts/attack_hit_box.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = 0.2
	timer.start()
	origin_point = global_position
	
	slash_attack_hb.set_shape(CapsuleShape2D.new(), Vector2($SlashHitBox.shape.radius, $SlashHitBox.shape.height))
	slash_attack_hb.rotate(PI/2)
	slash_attack_hb.set_damage(10)
	slash_attack_hb.set_knockback(2)
	slash_attack_hb.set_team(TEAM_ENUM.TEAM.PLAYER)
	slash_attack_hb.get_child(0).position = Vector2(-1 * scale.x, 4 * scale.y)
	
	slash_projectile_hb.set_new_hit_box_polygone($ProjectilHitBox)
	slash_projectile_hb.set_damage(3)
	slash_projectile_hb.set_knockback(3.5)
	slash_projectile_hb.set_team(TEAM_ENUM.TEAM.PLAYER)
	slash_projectile_hb.get_child(0).position = Vector2(-1.5, -0.3)
	slash_projectile_hb.get_child(0).disabled = true
	
	animated_sprite.play("Create")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !can_move or animated_sprite.animation == "Disapear":
		return
	animated_sprite.play("Travel")
	
	global_position.x += travelling_speed * delta * direction
	global_position.y = global_position.y
	
	if position.distance_to(origin_point) > travelling_distance :
		slash_projectile_hb.get_child(0).disabled = true
		animated_sprite.play("Disapear")

func set_direction(value : int):
	if value < 0:
		direction = -1
		scale.x = scale.x * -1
	elif value > 0:
		direction = 1
	else:
		direction = 0
		
func _on_timer_timeout() -> void:
	can_move = true
	slash_projectile_hb.get_child(0).disabled = false
	$SlashAttackHB.get_child(0).disabled = true



func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "Disapear":
		queue_free()

func _on_slash_projectile_hb_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		$GPUParticles2D.global_position = Vector2(body.global_position.x + 16, body.global_position.y - 16)
		$GPUParticles2D.emitting = true   # joue une fois puis s'arrêt
