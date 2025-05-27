extends Area2D

@onready var sprite = $Sprite2D3
var is_clicked = false
var is_correct = true # Set to true manually in the Inspector or script for the two correct ones

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_clicked:
			return
		is_clicked = true

		# Tint the sprite green
		sprite.modulate = Color(0, 1, 0)

		if is_correct:
			get_tree().call_group("game", "report_correct_selection")
