extends Sprite

signal SenseiText

var dialogNum = 0

func _ready() -> void:
	connect("SenseiText", get_tree().get_current_scene().get_node("UI").get_node("Textbox"), "_on_Text")
	
func _process(delta: float) -> void:
	if $Area2D.monitoring:
		if len($Area2D.get_overlapping_bodies()) > 0 and Input.is_action_pressed("talk"):
			if dialogNum == 1:
				if PlayerStats.Inventory.contains("Essence", 10):
					emit_signal("SenseiText", 2, $Area2D)	
				else:
					emit_signal("SenseiText", 1, $Area2D)	
			else:
				emit_signal("SenseiText", dialogNum, $Area2D)
				dialogNum = 1
