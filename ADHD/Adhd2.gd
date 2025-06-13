extends Control

@onready var star_button = $StarButton  # TextureButton for star
@onready var object_buttons = [
	$Object1,
	$Object2,
	$Object3,
	$Object4
]

@onready var label = $Label

# Fixed positions inside the Control node’s coordinate system
var fixed_positions = [
	Vector2(662, 498),  # StarButton
	Vector2(474, 276),  # ObjectButton1
	Vector2(174, 198),  # ObjectButton2
	Vector2(663, 228),  # ObjectButton3
	Vector2(325, 405)   # ObjectButton4
]

func _ready():
	_place_buttons()

	# Connect pressed signals
	star_button.connect("pressed", Callable(self, "_on_star_pressed"))
	for obj_btn in object_buttons:
		obj_btn.connect("pressed", Callable(self, "_on_wrong_button_pressed"))

func _place_buttons():
	star_button.position = fixed_positions[0]

	for i in range(object_buttons.size()):
		object_buttons[i].position = fixed_positions[i + 1]

func _on_star_pressed():
	label.text = "✅ Teisingai!"
	emit_signal("task_completed", true)

func _on_wrong_button_pressed():
	label.text = "❌ Neteisingai!"
	emit_signal("task_completed", false)

signal task_completed(correct: bool)

func is_correct() -> bool:
	return label.text == "✅ Teisingai!"  # or use a variable like `completed_correctly`
