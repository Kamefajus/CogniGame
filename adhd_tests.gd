extends Control

@onready var tab_container: TabContainer = $TabContainer
var last_tab_index: int = -1

func _ready() -> void:
	tab_container.connect("tab_changed", _on_tab_changed)
	_on_tab_changed(tab_container.current_tab)

func _on_tab_changed(tab_index: int) -> void:
	# Clear content from the previous tab
	if last_tab_index >= 0 and last_tab_index < tab_container.get_child_count():
		var last_tab_node = tab_container.get_child(last_tab_index)
		for child in last_tab_node.get_children():
			child.queue_free()

	# Construct path to scene file
	var scene_path := "res://ADHD/ADHD%d.tscn" % (tab_index + 1)
	var scene_res := load(scene_path)
	if not scene_res:
		push_error("Failed to load scene at: %s" % scene_path)
		return

	# Instantiate and add to current tab
	var instance = scene_res.instantiate()
	var current_tab_node = tab_container.get_child(tab_index)
	current_tab_node.add_child(instance)

	# Optional: apply layout if it's a Control node
	if instance is Control:
		instance.anchor_left = 0.0
		instance.anchor_top = 0.0
		instance.anchor_right = 1.0
		instance.anchor_bottom = 1.0
		instance.offset_left = 0
		instance.offset_top = 0
		instance.offset_right = 0
		instance.offset_bottom = 0

	last_tab_index = tab_index
