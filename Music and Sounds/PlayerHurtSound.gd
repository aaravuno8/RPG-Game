extends AudioStreamPlayer2D

func _on_PlayerHurtSound_finished() -> void:
	queue_free()
