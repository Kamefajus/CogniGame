# -------------- ColorProfile.gd ----------------
extends Node
##  Autoload that forces a fresh ColorBlindness node each time you
##  change `mode` or load another root scene.

var mode : String = "normal"    # "normal", "protanopia", …

const CB_SCENE : PackedScene = preload("res://addons/paulloz.colorblindness/ColorBlindness.tscn")
const MODE_TO_ENUM : Dictionary = {
	"normal":        0,
	"protanopia":    1,
	"deuteranopia":  2,
	"tritanopia":    3,
	"achromatopsia": 4
}

var _current_cb : CanvasLayer = null   # current instance (may be null)

# -------------------------------------------------------------------
func _ready() -> void:
	# Wait a frame to ensure the initial scene is ready
	await get_tree().process_frame
	_recreate_in_scene(get_tree().current_scene)
	get_tree().connect("tree_changed", Callable(self, "_on_tree_changed"))
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

func _on_tree_changed() -> void:
	var tree = get_tree()
	
	# Check if the tree is valid
	if tree == null:
		print("Scene tree is not valid.")
		return
	
	await tree.process_frame
	
	var current_scene = tree.current_scene
	
	# Check if the current scene is valid and if _current_cb is valid
	if current_scene and (!_current_cb or !is_instance_valid(_current_cb) or !_current_cb.is_inside_tree()):
		_recreate_in_scene(current_scene)


func _on_node_added(node: Node) -> void:
	# If the added node is a scene root, ensure we have our filter
	if node == get_tree().current_scene:
		await get_tree().process_frame
		_recreate_in_scene(node)

# Call this from your test after you set `mode`
func apply() -> void:
	await get_tree().process_frame
	_recreate_in_scene(get_tree().current_scene)

# -------------------------------------------------------------------
func _recreate_in_scene(scene: Node) -> void:
	if scene == null:
		return
		
	# remove previous instance (if any)
	if _current_cb:
		if is_instance_valid(_current_cb) and _current_cb.get_parent():
			_current_cb.queue_free()
		_current_cb = null

	# fresh node
	_current_cb = CB_SCENE.instantiate() as CanvasLayer
	if _current_cb:
		_current_cb.layer = 100                         # draw last
		scene.add_child(_current_cb)
		# Ensure it's moved to the end of the scene tree
		scene.move_child(_current_cb, scene.get_child_count() - 1)
		# set the requested mode
		_current_cb.Type = MODE_TO_ENUM.get(mode, 0)
		print("ColorBlindness filter recreated - Mode: " + mode)
