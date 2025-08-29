extends Node2D

@export var launch_speed := 800.0
@export var pull_speed := 500

var direction := Vector2.ZERO
var is_traveling := false
var is_hooked := false
var max_distance := 300.0
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
		current_distance += launch_speed * delta
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
		var to_grapple = current_position - player.global_position
		var distance = to_grapple.length()
		
		if distance > 20.0: # tolérance pour ne pas osciller
			var pull_direction = to_grapple.normalized()
			player.velocity = pull_direction * pull_speed
			
		else:
			# Arrivé au grappin
			reset()
		
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
	max_distance = 300.0
	current_distance = 0.0
	target_distance = 0.0
	start_position = Vector2.ZERO
	current_position = Vector2.ZERO
	ray.target_position = Vector2.ZERO
	line.clear_points()
	visible = false
	
func get_is_hooked() -> bool:
	return is_hooked
