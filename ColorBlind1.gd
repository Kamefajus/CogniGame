extends Node2D
signal triangle_clicked
func _ready():
	for triangle in get_tree().get_nodes_in_group("triangles"):
		triangle.connect("triangle_clicked", Callable(self, "_on_triangle_clicked"))

func _on_triangle_clicked():
	for node in get_tree().get_nodes_in_group("triangles"):
		if not node.clicked:
			return
	show_popup()

func show_popup():
	var popup = AcceptDialog.new()
	popup.dialog_text = "🎉 Visi trikampiai paspausti!"
	add_child(popup)
	popup.popup_centered()
