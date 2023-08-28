extends KinematicBody2D

export var ACCELERATION = 10
export var MAX_SPEED = 150
export var ROLL_SPEED = 170
export var FRICTION = 50

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var animType = null
var lastMovingInputVector = Vector2.DOWN
var stats = PlayerStats
var knockback  = Vector2.ZERO
var attack_sound_playing = false
var roll_sound_playing = false
var can_shockwave = true

signal attack

onready var swordHitbox = $Hitbox
onready var blinkAnimation = $BlinkAnimation
onready var hurtSoundEffect = preload("res://Music and Sounds/PlayerHurtSound.tscn")

func _ready() -> void:
	swordHitbox.knockback_vector = Vector2.DOWN
	stats.connect("no_health", self, "queue_free")	

func _process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, 200*delta)
	knockback = move_and_slide(knockback)
	
	if Input.is_action_just_pressed("shockwave"):
		magic_shockwave()
	
	match state:
		MOVE:
			move_state()
		ROLL:
			roll_state()
		ATTACK:
			attack_state()

func move_state():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		swordHitbox.knockback_vector = input_vector
		lastMovingInputVector = input_vector
		set_animation("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION)
	else:
		set_animation("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state():
	set_animation("Roll")
	velocity = lastMovingInputVector * 170
	velocity = move_and_slide(velocity)

func attack_state():
	velocity = Vector2.ZERO
	set_animation("Attack")
	
func move():
	velocity = move_and_slide(velocity)
	
func set_animation(anim_type):
	if not "Attack" in $AnimatedSprite.animation:
		var animationFuture = null
		var swordPositionFuture = null
		var swordRotationFuture = null
		if lastMovingInputVector.y > 0:
			animationFuture = anim_type + "Down"
			if anim_type == "Attack":
				swordPositionFuture = Vector2(11, 0)
				swordRotationFuture = 0
		elif lastMovingInputVector.y < 0:
			animationFuture = anim_type + "Up"
			if anim_type == "Attack":
				swordPositionFuture = Vector2(-20, 0)
				swordRotationFuture = 0
		if lastMovingInputVector.x > 0:
			animationFuture = anim_type + "Right"
			if anim_type == "Attack":
				swordPositionFuture = Vector2(-6, -18)
				swordRotationFuture = 90
		elif lastMovingInputVector.x < 0:
			animationFuture = anim_type + "Left"
			if anim_type == "Attack":
				swordPositionFuture = Vector2(-6, 18)
				swordRotationFuture = 90
		if animationFuture:
			$AnimatedSprite.play(animationFuture)
			if anim_type == "Attack":
				$Hitbox/CollisionShape2D.disabled = false
				$Hitbox/CollisionShape2D.position = swordPositionFuture
				$Hitbox/CollisionShape2D.rotation_degrees = swordRotationFuture
				$AttackDone.start(0.1)
		else:
			$AnimatedSprite.play(anim_type + "Down")
			if anim_type == "Attack":
				$Hitbox/CollisionShape2D.disabled = false
				$Hitbox/CollisionShape2D.position = Vector2(11, 0)
				$Hitbox/CollisionShape2D.rotation_degrees = 90
	if "Attack" in anim_type and !attack_sound_playing:
		$SwordSwipeSound.play()
		emit_signal("attack")
		attack_sound_playing = true
	if "Roll" in anim_type and !roll_sound_playing:
		$RollEvadeSound.play()
		roll_sound_playing = true

func _on_AnimatedSprite_animation_finished() -> void:
	if "Attack" in $AnimatedSprite.animation:
		attack_sound_playing = false
		$AnimatedSprite.play("IdleDown")
		state = MOVE
		state_over_idle_anim()
	if "Roll" in $AnimatedSprite.animation:
		roll_sound_playing = false
		state = MOVE
		state_over_idle_anim()

func state_over_idle_anim():
	set_animation("Idle")

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	$Hurtbox.start_invincibility(0.5)
	var soundEffect = hurtSoundEffect.instance()
	soundEffect.global_position = global_position
	get_parent().add_child(soundEffect)
	stats.health -= area.damage
	knockback = area.knockback_vector * 110

func _on_Hurtbox_invincibility_stated() -> void:
	blinkAnimation.play("start")

func _on_Hurtbox_invincibility_ended() -> void:
	blinkAnimation.play("stop")

func _on_AttackDone_timeout() -> void:
	$Hitbox/CollisionShape2D.disabled = true

func magic_shockwave() -> void:
	if stats.mana >= 30 and stats.researched.shockwave == true and can_shockwave:
		stats.mana -= 30
		$Hitbox/CollisionShapeShockwave.disabled = false
		$Hitbox.damage = 25
		$Hitbox/ShockwaveTimer.start(0.2)
		$Hitbox/ShockwaveTimeOut.start(5)
		can_shockwave = false

func _on_ShockwaveTimer_timeout() -> void:
	$Hitbox/CollisionShapeShockwave.disabled = true
	$Hitbox.damage = 1

func _on_Cave1Area2D_body_entered(body: Node) -> void:
	if body.name == self.name:
		get_tree().change_scene("res://Cave1.tscn")

func _on_ShockwaveTimeOut_timeout() -> void:
	can_shockwave = true
