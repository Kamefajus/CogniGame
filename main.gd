extends Control

@onready var score_label = $UI/ScoreLabel
@onready var end_label = $UI/EndLabel
@onready var spawner = $Spawner  # Now a Control

var score = 0
const MAX_SCORE = 5
const MIN_SCORE = -5
var object_scene = preload("res://ADHD/ObjectADHD.tscn")

func _ready():
	score = 0
	score_label.text = "Taškai: 0"
	end_label.visible = false
	spawn_objects()

func update_score(value: int):
	if score >= MAX_SCORE or score <= MIN_SCORE:
		return

	score += value
	score_label.text = "Taškai: %d" % score

	clear_objects()

	if score >= MAX_SCORE:
		end_label.text = "✅ Teisingai!"
		end_label.visible = true
		emit_signal("task_completed", true)
	elif score <= MIN_SCORE:
		show_lose_popup()
	else:
		await get_tree().create_timer(0.5).timeout
		spawn_objects()

func show_lose_popup():
	end_label.text = "❌ Neteisingai!"
	end_label.visible = true
	emit_signal("task_completed", false)
	# Optionally disable further input or spawning here

func spawn_objects():
	clear_objects()

	var rocket_spawned = false
	var rocket_position = Vector2.ZERO
	var objects_to_spawn = 3

	for i in range(objects_to_spawn):
		var obj = object_scene.instantiate()
		spawner.add_child(obj)
		obj.custom_minimum_size = Vector2(128, 128)
		obj.set_size(Vector2(128, 128))

		# Set spawn range to 900x450 with padding
		var spawn_position = Vector2(randi() % 800 + 50, randi() % 350 + 50)

		if not rocket_spawned:
			obj.set_as_rocket(true)
			rocket_position = spawn_position
			rocket_spawned = true
		else:
			var attempts = 0
			while spawn_position.distance_to(rocket_position) < 40 and attempts < 20:
				spawn_position = Vector2(randi() % 800 + 50, randi() % 350 + 50)
				attempts += 1
			obj.set_as_rocket(false)

		obj.main_node = self
		obj.set_position(spawn_position)


func clear_objects():
	for obj in spawner.get_children():
		obj.queue_free()
		
signal task_completed(correct: bool)

func is_correct() -> bool:
	return end_label.text == "✅ Teisingai!"  # or use a variable like `completed_correctly`
