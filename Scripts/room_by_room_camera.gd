extends Camera2D

var current_limits: Rect2
var target_limits: Rect2

@export var transition_speed: float = 2.0   # vitesse d’interpolation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_limits = Rect2(Vector2.ZERO, Vector2(1, 1))
	target_limits = current_limits
	pass # Replace with function body.

func set_room_limits(new_limits: Rect2):
	target_limits = new_limits

func _process(delta):
	if target_limits:
		# interpolation progressive
		current_limits.position = current_limits.position.lerp(target_limits.position, delta * transition_speed)
		current_limits.size     = current_limits.size.lerp(target_limits.size, delta * transition_speed)

		# mise à jour des limites de la caméra
		limit_left   = int(current_limits.position.x)
		limit_top    = int(current_limits.position.y)
		limit_right  = int(current_limits.position.x + current_limits.size.x)
		limit_bottom = int(current_limits.position.y + current_limits.size.y)
