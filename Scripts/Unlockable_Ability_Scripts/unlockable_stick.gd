extends Area2D


@onready var unlock_stick = %Player


func _on_body_entered(body):
	if body.is_in_group("player"):
		unlock_stick._unlock_stick()
		queue_free()
