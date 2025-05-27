extends CanvasLayer


func change_scene(next_scene: String, color: Color = Color.from_rgba8(246, 246, 232)) -> void:
	$ColorRect.color = color
	$AnimationPlayer.play("transition")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(next_scene)
	$AnimationPlayer.play_backwards("transition")


func change_scene_with_scene_instance(node: Node, color: Color = Color.from_rgba8(246, 246, 232)) -> void:
	$ColorRect.color = color
	$AnimationPlayer.play("transition")
	await $AnimationPlayer.animation_finished
	get_tree().current_scene.get_parent().add_child(node)
	get_tree().current_scene.queue_free()
	$AnimationPlayer.play_backwards("transition")


func new_node_with_call(node: String, fun: String, arg, color: Color = Color.from_rgba8(246, 246, 232)) -> void:
	var nextscene = load(node).instantiate()
	nextscene.call(fun, arg)
	change_scene_with_scene_instance(nextscene, color)


func change_scene_slide_animation(next_scene: String, is_up: bool) -> void:
	print("starting")
	if is_up:
		$AnimationPlayer.play("transition up 1part")
	else:
		$AnimationPlayer.play_backwards("transition up 2part")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(next_scene)
	if is_up:
		$AnimationPlayer.play("transition up 2part")
	else:
		$AnimationPlayer.play_backwards("transition up 1part")


func slide_animation_in_parts(part: int, is_up: bool) -> void:
	if is_up:
		if part == 1:
			$AnimationPlayer.play("transition up 1part")
		else:
			$AnimationPlayer.play("transition up 2part")
	else:
		if part == 1:
			$AnimationPlayer.play_backwards("transition up 2part")
		else:
			$AnimationPlayer.play_backwards("transition up 1part")
	await $AnimationPlayer.animation_finished
