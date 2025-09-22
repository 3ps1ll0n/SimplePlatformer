extends Area2D


@onready var unlock_dash = %Player


func _on_body_entered(body):
	if body.is_in_group("player"):
		unlock_dash._unlock_dash()
		queue_free()
