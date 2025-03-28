extends Node

@onready var click_sound = preload("res://sounds/ui_click_3.wav")  # Your sound file path

func play_click():
	var click = AudioStreamPlayer.new()
	click.stream = click_sound
	click.bus = "UI"  # Optional: route to a specific bus
	get_tree().get_root().add_child(click)
	
	# Randomize the pitch scale a little bit (e.g., from 0.9 to 1.1)
	click.pitch_scale = randf_range(1.0, 1.3)
	
	click.play()
	click.finished.connect(click.queue_free)
