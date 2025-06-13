# DropZone.gd
extends ColorRect

var is_occupied := false
var current_item = null

func _ready():
	add_to_group("drop_zones")
	color = Color(1, 1, 1, 0.3)
	update_appearance()

func update_appearance():
	if is_occupied:
		if current_item.is_in_correct_zone:
			modulate = Color(0.5, 1, 0.5) # Green for correct
		else:
			modulate = Color(1, 0.5, 0.5) # Red for incorrect
	else:
		modulate = Color(1, 1, 1) # White when empty
