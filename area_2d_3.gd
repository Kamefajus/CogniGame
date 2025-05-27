extends Area2D

func _ready():
	# Optional: enable mouse input on the sprite
	input_pickable = true

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Sprite clicked!")
		$Sprite2D3.modulate = Color(0, 1, 0)  # Change to green
		show_popup()

func show_popup():
	var popup := AcceptDialog.new()
	popup.dialog_text = "Neteisingai! Bandyk dar kartą"
	add_child(popup)
	popup.popup_centered()
