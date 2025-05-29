extends Control

@onready var tab_container: TabContainer = $TabContainer
var last_tab_index: int = -1
var current_scene: Node = null

func _ready() -> void:
	tab_container.connect("tab_changed", _on_tab_changed)
	# Load scene for the initial tab
	_on_tab_changed(tab_container.current_tab)

func _on_tab_changed(tab_index: int) -> void:
	var current_tab_node = tab_container.get_child(tab_index)

	# Deactivate and remove old scene if exists
	if current_scene:
		if current_scene.has_method("on_tab_exited"):
			current_scene.call("on_tab_exited")
		else:
			# Fallback deactivate method if you want consistency
			if current_scene.has_method("deactivate"):
				current_scene.call("deactivate")
		current_scene.queue_free()
		current_scene = null

	# Clear old children from the current tab container (except UI elements if needed)
	for child in current_tab_node.get_children():
		child.queue_free()

	# Load new scene according to tab index
	var scene_path := "res://ADHD/ADHD%d.tscn" % (tab_index + 1)
	var scene_res := load(scene_path)
	if not scene_res:
		push_error("Failed to load scene: %s" % scene_path)
		return

	current_scene = scene_res.instantiate()
	current_tab_node.add_child(current_scene)

	# Wait one frame to let UI update properly
	await get_tree().process_frame

	# Redraw if scene is a Control node
	if current_scene is Control:
		current_scene.queue_redraw()

	# Call custom activation method on the scene
	if current_scene.has_method("on_tab_entered"):
		current_scene.call("on_tab_entered")
	else:
		# Fallback activate method
		if current_scene.has_method("activate"):
			current_scene.call("activate")

	last_tab_index = tab_index
