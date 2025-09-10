extends CharacterBody2D

@export var max_health := 100
var current_health := max_health

func _ready() -> void:
	add_to_group("enemies")

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()
