extends Node2D

var inventory = [false, false, false, false, false, false, false, false, false]
var inventoryCount = [0, 0, 0, 0, 0, 0, 0, 0, 0]
var inventoryLocations = [88, 106, 124, 142, 160, 178, 196, 214, 232]
var invSlotSelected = 0
var heldItem = false
onready var highlight = $Highlight

func _process(delta: float) -> void:
	for i in range(9):
		if Input.is_action_just_pressed("inv"+str(i+1)):
			highlight.position.x = inventoryLocations[i]
			invSlotSelected = i
			heldItem = inventory[i]

func addItem(itemName, itemCount):
	if self.get_path() != "/root/Inventory":
		var invIdx = inventory.find(false)
		get_tree().get_current_scene().get_node("UI/Inventory/InventoryBox"+str(invIdx+1)+"/Sprite").set_texture(load("res://Items/"+itemName+".png"))
		inventory[invIdx] = itemName
		inventoryCount[invIdx] = itemCount
		heldItem = inventory[invSlotSelected]

func contains(itemName, itemCount):
	print(inventory)
	print(inventory.find(itemName))
