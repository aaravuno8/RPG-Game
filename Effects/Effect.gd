extends AnimatedSprite

func _ready() -> void:
	self.connect("animation_finished", self, "on_anim_finished")
	play("Animate")

func on_anim_finished() -> void:
	queue_free()
