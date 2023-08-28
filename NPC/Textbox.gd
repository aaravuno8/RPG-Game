extends Sprite

var speech = [["Hello! Our village is facing trouble! You must help us! \nPress Space to continue", "There is a cave up ahead. It is filled with monsters! At night, they come and attack our village!", "Please help us by clearing the cave!", "I will give you something to help you defeat the monsters.", "Bring me 10 essence to prove you have done the task"], ["Bring me 10 monster essence"], ["You have done it!", "You know what, I'll upgrade your sword as a thank you!"]]
var itemsGiven = ["Sword1", false, "Sword2"]

signal pressedEnter

func _ready() -> void:
	visible = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("pressedEnter")

func _on_Text(speechId, npcPath) -> void:
	visible = true
	npcPath.set_deferred("monitoring", false)
	for j in range(len(speech[speechId])):
		var text = speech[speechId][j]
		for i in range(len(text)+1):
			var textDisplay = text.substr(0, i)
			$Label.text = textDisplay
			var t = Timer.new()
			t.set_wait_time(0.03)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
		yield(self, "pressedEnter")
	visible = false
	npcPath.set_deferred("monitoring", true)
	print(itemsGiven[speechId])
	if str(itemsGiven[speechId]) != "False":
		PlayerStats.Inventory.addItem(itemsGiven[speechId], 1)
		itemsGiven[speechId] = false
