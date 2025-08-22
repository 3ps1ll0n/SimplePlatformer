extends Node2D

@export var speed := 600.0
var direction := Vector2.ZERO
var is_traveling := false
var is_hooked := false
var max_distance := 100.0
var current_distance := 0.0
var target_distance := 0.0
var start_position := Vector2.ZERO
var current_position:= Vector2.ZERO
var player: CharacterBody2D

@onready var line := $Line2D
@onready var ray := $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D

func fire(p: CharacterBody2D, to_position: Vector2) -> void:
	
	if is_hooked:
		reset()
		return
	
	visible = true
	position = Vector2(0, 0)
	player = p
	var from_position = player.position
	start_position = from_position
	direction = (to_position - from_position).normalized()
	target_distance = max_distance
	current_distance = 0.0
	current_position = start_position
	
	is_traveling = true

func _process(delta: float) -> void:
	if is_traveling:
		current_distance += speed * delta
		# Enable RayCast2D to check hit 
		ray.target_position = current_position - start_position
		ray.position = start_position
		ray.enabled = true
		ray.force_raycast_update()
		if ray.is_colliding():
			#print("Hit:", ray.get_collider())
			is_traveling = false
			is_hooked = true
		
		elif current_distance >= target_distance:
			current_distance = target_distance
			is_traveling = false
			
		# Update rope drawing
		update_rope()
	elif not is_hooked:
		reset()
		pass
	elif player:
		var distance_to_grapple = player.global_position.distance_to(current_position) #current position is the final position in this case
		
		if distance_to_grapple > max_distance:
			var pull_direction = (current_position - player.global_position).normalized()
			var pull_strength = (distance_to_grapple - max_distance) * 100.0  # Tune this multiplier
			player.velocity += pull_direction * pull_strength * delta
		
		follow_player()
		

func update_rope() -> void:
	line.clear_points()
	line.add_point(player.global_position)
	current_position = start_position + direction * current_distance
	line.add_point(current_position)
	sprite.position = current_position
	#position = player.global_position
	
func follow_player() -> void:
	line.clear_points()
	line.add_point(player.global_position)
	line.add_point(current_position)
	#position = player.global_position
	pass

func reset():
	direction = Vector2.ZERO
	is_traveling = false
	is_hooked = false
	max_distance = 100.0
	current_distance = 0.0
	target_distance = 0.0
	start_position = Vector2.ZERO
	current_position = Vector2.ZERO
	ray.target_position = Vector2.ZERO
	line.clear_points()
	visible = false
	
