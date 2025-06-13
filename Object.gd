extends TextureButton

var is_rocket := false
var main_node: Control = null

func _ready():
	connect("pressed", self._on_pressed)

func set_as_rocket(value: bool) -> void:
	is_rocket = value
	if is_rocket:
		texture_normal = preload("res://May 20, 2025, 05_29_39 PM.png")
	else:
		texture_normal = preload("res://Red-Circle-Transparent.png")

func _on_pressed():
	if main_node:
		main_node.update_score(1 if is_rocket else -1)
	queue_free()
