# FadeLayer.gd
extends ColorRect
signal faded_out

func _ready():
	modulate.a = 1.0 # Kad pradžioje būtų pilnai matomas
	visible = true

func hard_fade_out(duration := 0.3):
	get_parent().visible = true
	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration)
	tween.finished.connect(func(): emit_signal("faded_out"))

func hard_fade_in(duration := 0.3):
	var control = get_tree().root.get_node("/root/Control")
	get_tree().root.move_child(control, control.get_parent().get_child_count())
	visible = true
	modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.finished.connect(func(): get_parent().visible = false)
	
