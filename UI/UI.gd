extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heartUIEmpty = $HeartUIEmpty
onready var heartUIFull = $HeartUIFull
onready var researchMeter = get_parent().get_node("Research/ResearchMeter")
onready var researchLabel = get_parent().get_node("Research/Label")
onready var researchEnd = get_parent().get_node("Research/ResearchMeterEnd")
onready var manaMeter = get_parent().get_node("Mana/ManaMeter")
onready var manaLabel = get_parent().get_node("Mana/Label")
onready var manaEnd = get_parent().get_node("Mana/ManaMeterEnd")

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull:
		heartUIFull.rect_size.x = hearts * 15

func set_research(value):
	if value < 19.999 and researchMeter:
		researchMeter.scale.x = value / 10
		var displayValue = value + value / 4
		researchEnd.visible = false
		researchLabel.text = "Research: " + str(displayValue) + "/25"
	else:
		researchMeter.scale.x = value / 10
		researchEnd.visible = true
		researchLabel.text = "Research: 25/25"

func set_mana(value):
	if value < 99.999 and manaMeter:
		manaMeter.scale.x = value * 0.02
		manaEnd.visible = false
		manaLabel.text = "Mana: " + str(value) + "/100"
	else:
		manaMeter.scale.x = 1.95
		manaEnd.visible = true
		manaLabel.text = "Mana: 100/100"

func set_max_hearts(value):
	max_hearts = max(value, 1)
	if heartUIEmpty:
		heartUIEmpty.rect_size.x = max_hearts * 15

func _ready() -> void:
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("research_changed", self, "set_research")
	PlayerStats.connect("mana_changed", self, "set_mana")
