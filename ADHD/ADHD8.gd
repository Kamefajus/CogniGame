extends Node2D

const NUM_OTHER_FACES := 20
const FACE_SIZE := Vector2(16, 16)  # dar mažesni
const SPACING := 100
const MAX_ATTEMPTS := 200

var placed_faces := []
var result_label: Label

var face_textures := {
	"smile": preload("res://ChatGPT Image May 24, 2025, 01_49_09 PM.png"),
	"sad": preload("res://ChatGPT Image May 24, 2025, 01_50_51 PM.png"),
	"angry": preload("res://ChatGPT Image May 24, 2025, 01_52_53 PM.png")
}

func _ready():
	randomize()

	# Naudojame esamą ResultLabel iš scenos
	result_label = $ResultLabel
	result_label.text = ""
	result_label.visible = false

	# Sukuriame besišypsantį veidą
	var smile_face = create_face("smile")
	smile_face.pressed.connect(_on_smile_pressed)
	add_child(smile_face)

	# Sukuriame kitus veidus
	for i in NUM_OTHER_FACES:
		var mood = "sad" if randf() > 0.5 else "angry"
		var other_face = create_face(mood)
		other_face.pressed.connect(_on_wrong_pressed)
		add_child(other_face)

func create_face(mood: String) -> TextureButton:
	var face = TextureButton.new()
	face.texture_normal = face_textures[mood]
	face.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	face.custom_minimum_size = FACE_SIZE
	face.scale = Vector2(0.15, 0.15)  # sumažintas vaizdas
	place_face_randomly(face)
	return face

func place_face_randomly(face: TextureButton):
	var rect = Rect2()
	var attempt := 0
	while attempt < MAX_ATTEMPTS:
		var pos = Vector2(
			randf_range(0, get_viewport_rect().size.x - FACE_SIZE.x),
			randf_range(0, get_viewport_rect().size.y - FACE_SIZE.y)
		)
		rect.position = pos
		rect.size = FACE_SIZE

		var overlaps = false
		for existing in placed_faces:
			if existing.intersects(rect.grow(SPACING)):
				overlaps = true
				break

		if not overlaps:
			face.position = pos
			placed_faces.append(rect)
			return
		attempt += 1

func _on_smile_pressed():
	_show_result("✅ Teisingai!", Color.GREEN)

func _on_wrong_pressed():
	_show_result("❌ Neteisingai.", Color.RED)

func _show_result(text: String, color: Color):
	result_label.text = text
	result_label.add_theme_color_override("font_color", color)
	result_label.visible = true
	await get_tree().create_timer(2.0).timeout
	result_label.visible = false
func on_tab_entered():
	set_process(true)
	set_physics_process(true)
	visible = true
	# Resume timers, animations, etc.

func on_tab_exited():
	set_process(false)
	set_physics_process(false)
	visible = false


func _on_button1_pressed() -> void:
	get_tree().change_scene_to_file("res://ADHD/ADHD7.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://ADHD/ADHD9.tscn")
