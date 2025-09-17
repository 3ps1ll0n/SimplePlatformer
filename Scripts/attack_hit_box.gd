extends Area2D
@onready var collision_shape = $CollisionShape2D

enum TEAM {
	UNDIFINED,
	PLAYER,
	ENEMY
}

var team := TEAM.UNDIFINED
var damage := 0

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):   # Assure-toi que tes ennemis sont dans ce groupe
		body.take_damage(damage)
		var player := get_parent().get_parent()
		if player is CharacterBody2D:
			body.take_knockback(player.position)
	elif body.is_in_group("player"):
		body.take_damage(damage)
		var ennemi := get_parent().get_parent()
		body.take_knockback(ennemi.position)


func set_shape(shape: Shape2D, size: Vector2) -> void:
	collision_shape.shape = shape
	if shape is RectangleShape2D:
		shape.size = size
	elif shape is CapsuleShape2D:
		shape.radius = size.x
		shape.height = size.y
	elif shape is CircleShape2D:
		shape.radius = size.x

func set_properties(damage: int, team: TEAM, shape: Shape2D, size: Vector2):
	self.team = team
	self.damage = damage
	
	collision_shape.shape = shape
	if shape is RectangleShape2D:
		shape.size = size
	elif shape is CapsuleShape2D:
		shape.radius = size.x
		shape.height = size.y
	elif shape is CircleShape2D:
		shape.radius = size.x
	pass
