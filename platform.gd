extends StaticBody2D

var is_occupied = false
var allowed_node_name
var current_object = null

func _ready() -> void:
	match name:
		"platform":
			allowed_node_name = "Node2D3"
		"platform2":
			allowed_node_name = "Node2D"
		"platform3":
			allowed_node_name = "Node2D2"
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)


func _process(delta: float) -> void:
	visible = Global1.is_dragging
