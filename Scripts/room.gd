extends Area2D

func collision_shape_to_rect2(collision_shape: CollisionShape2D) -> Rect2:
	if collision_shape.shape is RectangleShape2D:
		var rect_shape: RectangleShape2D = collision_shape.shape

		# Taille du rectangle (shape.extents = moitié de la taille)
		var size = rect_shape.extents * 2

		# Position dans la scène (on combine le transform du node)
		var pos = collision_shape.global_position - rect_shape.extents

		return Rect2(pos, size)
	else:
		push_warning("CollisionShape2D n'est pas un RectangleShape2D")
		return Rect2()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		var cam = get_viewport().get_camera_2d()
		var rect : CollisionShape2D = get_child(0) 
		cam.set_room_limits(collision_shape_to_rect2(rect))
