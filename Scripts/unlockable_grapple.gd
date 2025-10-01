extends Area2D


@onready var unlock_grapple = %Player


func _on_body_entered(body):
	if body.is_in_group("player"):
		unlock_grapple._unlock_grapple()
		queue_free()
