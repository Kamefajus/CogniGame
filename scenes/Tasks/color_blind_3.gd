# GameController.gd
extends Control

@onready var result_label: Label = $ResultLabel
var all_draggables = []
var all_drop_zones = []

func _ready():
	add_to_group("game_controller")
	all_draggables = get_tree().get_nodes_in_group("draggables")
	all_drop_zones = get_tree().get_nodes_in_group("drop_zones")
	result_label.visible = false

func check_win_condition():
	# Check if all drop zones are occupied
	var all_zones_filled = true
	for zone in all_drop_zones:
		if not zone.is_occupied:
			all_zones_filled = false
			break
	
	if not all_zones_filled:
		result_label.visible = false
		return
	
	# Check if all items are in correct zones
	var all_correct = true
	for item in all_draggables:
		if not item.is_in_correct_zone:
			all_correct = false
			break
	
	result_label.text = "✅ Teisingai! 🎉" if all_correct else "❌ Neteisingai!"
	result_label.add_theme_color_override("font_color", Color(1, 1, 1) if all_correct else Color(1, 1, 1))
	result_label.visible = true
	
	# Animate result
	var tween = create_tween()
	tween.tween_property(result_label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(result_label, "scale", Vector2(1.0, 1.0), 0.3)
	
	# Hide after delay if incorrect
	if not all_correct:
		tween.tween_callback(func(): result_label.visible = false).set_delay(2.0)
