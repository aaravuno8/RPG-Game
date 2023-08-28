extends Area2D

var invincible = false setget set_invincible

onready var collisionShape = $CollisionShape2D

signal invincibility_stated
signal invincibility_ended

func set_invincible(value) -> void:
	invincible = value
	if invincible == true:
		emit_signal("invincibility_stated")
	else:
		emit_signal("invincibility_ended")

func _on_Timer_timeout() -> void:
	self.invincible = false

func start_invincibility(duration) -> void:
	self.invincible = true
	$Timer.start(duration)

func _on_Hurtbox_invincibility_stated() -> void:
	collisionShape.set_deferred("disabled", true)

func _on_Hurtbox_invincibility_ended() -> void:
	collisionShape.disabled = false
