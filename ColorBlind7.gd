extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	show_popup_Bad()


func _on_button_2_pressed() -> void:
	show_popup()


func _on_button_3_pressed() -> void:
	show_popup_Bad()


func _on_button_4_pressed() -> void:
	show_popup_Bad()
func show_popup():
	var popup := AcceptDialog.new()
	popup.dialog_text = "Teisingai!"
	add_child(popup)
	popup.popup_centered()
	
func show_popup_Bad():
	var popup := AcceptDialog.new()
	popup.dialog_text = "Neteisingai! Bandyk dar kartą"
	add_child(popup)
	popup.popup_centered()
