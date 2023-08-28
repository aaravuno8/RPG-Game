extends Area2D

export var damage = 1
export var knockback_vector = Vector2.ZERO

func _on_Player_attack() -> void:
	if is_instance_valid(PlayerStats.Inventory):
		if str(PlayerStats.Inventory.heldItem) == "Sword1":
			damage = 2
