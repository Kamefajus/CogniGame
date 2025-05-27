extends Area2D

var clicked = false
signal triangle_clicked
func _ready():
	add_to_group("triangles")

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and not clicked:
		clicked = true
		$Polygon2D.modulate = Color(0, 1, 0)
		emit_signal("triangle_clicked")

func check_all_clicked():
	for node in get_tree().get_nodes_in_group("triangles"):
		if not node.clicked:
			return
	get_tree().root.get_node("MainNode").show_popup()  # Adjust path as needed
