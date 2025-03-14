extends Node

@onready var click_sound = preload("res://sounds/ui_click.wav")  # Your sound file path

func play_click():
	var click = AudioStreamPlayer.new()
	click.stream = click_sound
	click.bus = "UI"  # Optional: route to a specific bus
	get_tree().get_root().add_child(click)
	click.play()
	click.finished.connect(click.queue_free)
