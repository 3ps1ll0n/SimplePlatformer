extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		var player : CharacterBody2D = get_tree().get_nodes_in_group("player").get(0)
		var dir = player.get_attack_direction() * -1
		player.push_player(Vector2(500, 500) * dir)
		animated_sprite.play("Pop")


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "Pop":
		queue_free()
