extends Area2D

var player : CharacterBody2D

enum TEAM {
	UNDIFINED,
	PLAYER,
	ENEMY
}

var team := TEAM.UNDIFINED
var damage := 0
var knock_back_multiplier = 1.0
var collision_shape
var from_entity : CharacterBody2D = null

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	collision_shape = get_child(0)
	player = get_tree().get_first_node_in_group("player")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and team != TEAM.ENEMY:   # Assure-toi que tes ennemis sont dans ce groupe
		body.take_knockback(player.position, knock_back_multiplier)
		if player.get_attack_direction() == Vector2.DOWN and not body.is_dead():
			player.velocity.y = -250
		body.take_damage(damage)
		
	elif body.is_in_group("player") and team != TEAM.PLAYER:
		body.take_damage(damage)
		var ennemi := get_parent()
		body.take_knockback(ennemi.position)
		body.trigger_invincibility()


func set_shape(shape: Shape2D, size: Vector2) -> void:
	collision_shape.shape = shape
	if shape is RectangleShape2D:
		shape.size = size
	elif shape is CapsuleShape2D:
		shape.radius = size.x
		shape.height = size.y
	elif shape is CircleShape2D:
		shape.radius = size.x

func set_properties(damage_value: int, hb_team: TEAM, shape: Shape2D, size: Vector2):
	team = hb_team
	damage = damage_value
	
	set_shape(shape, size)

func set_new_hit_box(hb : CollisionShape2D):
	var new_shape = hb.shape.duplicate() # copie indépendante
	var my_shape : CollisionShape2D = get_child(0) # celui à remplacer
	my_shape.shape = new_shape
	
func set_new_hit_box_polygone(hb : CollisionPolygon2D):
	var new_poly = CollisionPolygon2D.new()
	new_poly.polygon = hb.polygon.duplicate()  # makes a copy of the array
	remove_child(get_child(0))
	add_child(new_poly)

func set_knockback(kb_multiplier : float):
	knock_back_multiplier = kb_multiplier

func set_damage(damage_value: int):
	damage = damage_value
	
func set_team(hb_team: TEAM):
	team = hb_team
