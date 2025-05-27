extends Node2D


var correct_found = 0
var popup_label

func _ready():
	# Create the popup label
	popup_label = Label.new()
	popup_label.text = "Teisingai!"
	popup_label.visible = false
	popup_label.set_position(Vector2(300, 200)) # Adjust as needed
	popup_label.set("theme_override_colors/font_color", Color(0, 1, 0)) # Green text
	popup_label.set_anchors_preset(Control.PRESET_CENTER)
	popup_label.set_scale(Vector2(2, 2)) # Make it bigger
	add_child(popup_label)

	add_to_group("game")

func report_correct_selection():
	correct_found += 1
	if correct_found == 2:
		popup_label.visible = true
