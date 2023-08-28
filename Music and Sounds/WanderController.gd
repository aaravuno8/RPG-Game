extends Node2D

const wander_range = 32

onready var start_position = global_position
onready var target_position = global_position

func _on_Timer_timeout() -> void:
	update_target_position()

func get_time_left():
	return $Timer.time_left

func start_wander_timer(duration):
	$Timer.start(duration)

func update_target_position():
	var target_vector = Vector2(rand_range(-wander_range, wander_range), rand_range(-wander_range, wander_range))
	target_position = start_position + target_vector
