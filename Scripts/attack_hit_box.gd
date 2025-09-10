extends Area2D
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):   # Assure-toi que tes ennemis sont dans ce groupe
		body.take_damage(100)           # Appelle une fonction de dégâts
		pass


func set_shape(shape: Shape2D, size: Vector2) -> void:
	collision_shape.shape = shape
	if shape is RectangleShape2D:
		shape.size = size
	elif shape is CapsuleShape2D:
		shape.radius = size.x
		shape.height = size.y
	elif shape is CircleShape2D:
		shape.radius = size.x
