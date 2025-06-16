extends Control

# Array to hold our scene paths
const SCENE_PATHS = [
	"res://scenes/Tasks/ColorBlind1.tscn",
	"res://scenes/Tasks/ColorBlind2.tscn",
	"res://scenes/Tasks/ColorBlind3.tscn",
	"res://scenes/Tasks/ColorBlind4.tscn",
	"res://scenes/Tasks/ColorBlind5.tscn",
	"res://scenes/Tasks/ColorBlind6.tscn",
	"res://scenes/Tasks/ColorBlind7.tscn",
	"res://scenes/Tasks/ColorBlind8.tscn",
	"res://PuzzleSolve.tscn",
	"res://ColorOrderGame.tscn"
]

var current_scene = null
var current_scene_index = -1  # Start with no scene loaded
var tabs = []

# ✅ Tracking logic
var completed_scenes := {}  # Dictionary: scene index → true if completed correctly
var correct_completion_count := 0

@onready var scene_container = $SceneContainer
@onready var tab_container = $TabContainer/MarginContainer/HBoxContainer
@onready var next_button = $Navigation/NextButton

func _ready():
	var AI = get_node("/root/AiHelper")
	AI.visible = true
	mouse_filter = MOUSE_FILTER_PASS
	scene_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	create_tab_buttons()
	next_button.connect("pressed", Callable(self, "_on_next_button_pressed"))
	# Optionally load the first scene
	# show_scene(0)

func create_tab_buttons():
	for i in range(SCENE_PATHS.size()):
		var button = Button.new()
		button.text = "%d" % (i + 1)
		button.connect("pressed", Callable(self, "show_scene").bind(i))
		tab_container.add_child(button)
		tabs.append(button)
		
		# Style buttons (optional)
		button.add_theme_font_size_override("font_size", 16)
		button.custom_minimum_size = Vector2(20, 20)

func show_scene(index):
	if index == current_scene_index:
		return

	if current_scene:
		scene_container.remove_child(current_scene)
		current_scene.queue_free()
		current_scene = null

	var scene_resource = load(SCENE_PATHS[index])
	current_scene = scene_resource.instantiate()
	scene_container.add_child(current_scene)
	current_scene_index = index

	# ✅ Connect the scene's signal
	if current_scene.has_signal("task_completed"):
		current_scene.connect("task_completed", Callable(self, "_on_task_completed").bind(index))

	update_tab_buttons()
	update_next_button_state()

func _on_task_completed(correct: bool, scene_index: int):
	if correct:
		if not completed_scenes.has(scene_index):
			completed_scenes[scene_index] = true
			correct_completion_count += 1
			print("✅ Scene", scene_index + 1, "completed correctly.")
	else:
		print("❌ Scene", scene_index + 1, "completed incorrectly.")

	print("🧠 Total correct scenes so far:", correct_completion_count, "/", SCENE_PATHS.size())
	var AI = get_node("/root/AiHelper")
	AI.visible = false

func update_tab_buttons():
	for i in range(tabs.size()):
		if i == current_scene_index:
			tabs[i].disabled = true
			tabs[i].add_theme_color_override("font_color", Color.WHITE)
		else:
			tabs[i].disabled = false
			tabs[i].add_theme_color_override("font_color", Color.GRAY)

func _on_next_button_pressed():
	var next_index = current_scene_index + 1
	if next_index >= SCENE_PATHS.size():
		next_index = 0  # Loop to first scene
	show_scene(next_index)

func update_next_button_state():
	# Optionally disable if on last scene or customize behavior
	pass

# ✅ Optional utility: check if all scenes completed correctly
func all_scenes_completed_correctly() -> bool:
	return completed_scenes.size() == SCENE_PATHS.size()
