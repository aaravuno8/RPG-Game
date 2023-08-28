extends KinematicBody2D

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE
}
const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO
var state = IDLE
var velocity = Vector2.ZERO
var player

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var agent = $NavigationAgent2D
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, 200*delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200*delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_random_state([IDLE, WANDER])
				wanderController.start_wander_timer(rand_range(1, 3))
			accelerate_towards_point(wanderController.target_position)
			if global_position.distance_to(wanderController.target_position) > 5:
				move_and_slide(velocity)
				$AnimatedSprite.flip_h = velocity.x < 0
		CHASE:
			chase_player()

func seek_player():
	if playerDetectionZone.can_see_player():
		player = playerDetectionZone.player
		state = CHASE

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	$Hurtbox.start_invincibility(0.3)
	knockback = area.knockback_vector * 120	

func _on_Stats_no_health() -> void:
	if name == "Necromancer":
		PlayerStats.Inventory.addItem("Essence", 2)
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	enemyDeathEffect.global_position = global_position
	get_parent().add_child(enemyDeathEffect)

func chase_player():
	if is_instance_valid(player):
		agent.set_target_location(player.global_position)
		var direction = global_position.direction_to(agent.get_next_location()).normalized()
		$Hitbox.knockback_vector = direction
		var steering = (direction * 50 - velocity)
		velocity += steering
		
		if softCollision.is_colliding():
			velocity += softCollision.get_push_vector() * 10
		
		velocity = move_and_slide(velocity)
		$AnimatedSprite.flip_h = velocity.x < 0
	else:
		state = IDLE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func accelerate_towards_point(point):
	var direction = global_position.direction_to(point)
	var steering = (direction * 25 - velocity)
	velocity += steering

func _on_Hurtbox_invincibility_ended() -> void:
	$AnimationPlayer.play("stop")

func _on_Hurtbox_invincibility_stated() -> void:
	$AnimationPlayer.play("start")
