extends Node

export(int) var max_health = 2 setget set_max_health
var health : int = max_health setget set_health
var research : float = 0 setget set_research
var mana : int = 99 setget set_mana
var researched = {"shockwave": true}
onready var Inventory = get_tree().get_current_scene().get_node("UI/Inventory")

signal no_health
signal health_changed(value)
signal research_changed(value)
signal mana_changed(value)
signal max_health_changed(value)

func _ready() -> void:
	self.health = max_health

func _process(delta: float) -> void:
	print(is_instance_valid(Inventory))
	if !is_instance_valid(Inventory):
		var Inventory = get_tree().get_current_scene().get_node("UI/Inventory")

func set_mana(value):
	mana = value
	emit_signal("mana_changed", mana)

func set_research(value):
	research = value
	emit_signal("research_changed", research)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func set_max_health(value):
	max_health = value
	emit_signal("max_health_changed", health)

func reset_health():
	self.set_health(max_health)

func _on_Mana_Timeout() -> void:
	if mana < 100:
		self.mana += 1
