extends Node2D

var map_size = 20
var tile_size = 0
var board = []
var head_index = 0
var tails: Array = []

var tail_length = 0
var apple_index = 0
var game_over = false
var movement = 0  # 1=left, 2=right, 3=up, 4=down
var next_movement = 0
var button_created := false 
var timer = 0.0
var move_interval = 0.15
var score = 0


var head_rotation_radians = 0.0
var target_rotation_radians = 0.0
var rotate_speed = 8.0

var font: Font
var head_texture: Texture2D
var body_straight_texture: Texture2D
var body_turn_left_texture: Texture2D
var body_turn_right_texture: Texture2D
var tail_texture: Texture2D
var apple_texture: Texture2D

var eat_sound: AudioStreamRandomizer
var head_scale = 1.0

var apples_in_tail: Array = []  # Kad sekam obuolį kūnu
@onready var pause_scene = preload("res://scenes/Pause.tscn")
var pause = null

func _ready():
	randomize()
	
	head_texture = preload("res://assets/snake/head.png")
	body_straight_texture = preload("res://assets/snake/body2.png")
	body_turn_left_texture = preload("res://assets/snake/body_turn2.png")
	body_turn_right_texture = preload("res://assets/snake/body_turn_right 2.png")
	tail_texture = preload("res://assets/snake/tail2.png")
	font = load("res://Game Bubble.ttf")
	apple_texture = load("res://assets/snake/apple.png")

	generate_board()
	place_snake()
	place_apple()
	eat_sound = AudioStreamRandomizer.new()
	eat_sound.add_stream(-1, preload("res://sounds/snakeSounds/eatSound1.mp3"))
	eat_sound.add_stream(-1, preload("res://sounds/snakeSounds/eatSound2.mp3"))
	eat_sound.add_stream(-1, preload("res://sounds/snakeSounds/eatSound3.mp3"))
	eat_sound.add_stream(-1, preload("res://sounds/snakeSounds/eatSound4.mp3"))

func _input(ev):
	if Input.is_action_just_pressed("ui_cancel"):
		if pause == null:
			pause = pause_scene.instantiate()
			get_tree().get_root().add_child(pause)
			get_tree().paused = true 
			pause.process_mode = Node.PROCESS_MODE_ALWAYS
		elif pause != null and pause.visible == true:
			get_tree().get_root().remove_child(pause)
			pause = null
			get_tree().paused = false


func _process(delta: float) -> void:
	if not game_over:
		timer += delta
		if timer >= move_interval:
			if next_movement != 0:
				movement = next_movement
				match movement:
					1: target_rotation_radians = deg_to_rad(270)
					2: target_rotation_radians = deg_to_rad(90)
					3: target_rotation_radians = deg_to_rad(0)
					4: target_rotation_radians = deg_to_rad(180)
				next_movement = 0

			move_snake()
			timer = 0.0

		head_rotation_radians = lerp_angle(head_rotation_radians, target_rotation_radians, delta * rotate_speed)
		head_scale = lerp(head_scale, 1.0, delta * 5.0)

	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		return

	if event.is_action_pressed("ui_left") and movement != 2:
		next_movement = 1
	elif event.is_action_pressed("ui_right") and movement != 1:
		next_movement = 2
	elif event.is_action_pressed("ui_up") and movement != 4:
		next_movement = 3
	elif event.is_action_pressed("ui_down") and movement != 3:
		next_movement = 4

func _draw():
	var vp_size = get_viewport_rect().size
	var side_len = min(vp_size.x, vp_size.y)
	var board_start_x = (vp_size.x - side_len) * 0.5

	draw_rect(Rect2(Vector2(board_start_x, 0), Vector2(side_len, side_len)), Color.WHITE, false)

	# Obuolys
	if apple_index > 0 and apple_index <= board.size():
		var a = board[apple_index - 1]
		var center = Vector2(a.x + tile_size * 0.5, a.y + tile_size * 0.5)
		draw_set_transform(center)
		draw_texture_rect(apple_texture, Rect2(Vector2(-tile_size * 0.5, -tile_size * 0.5), Vector2(tile_size, tile_size)), false)
		draw_set_transform(Vector2(), 0.0)

	# Kūnas
	for n in range(1, tail_length + 1):
		if n >= tails.size():
			continue

		var tile = board[tails[n] - 1]
		var center = Vector2(tile.x + tile_size * 0.5, tile.y + tile_size * 0.5)

		var from_idx = tails[n + 1] if (n < tail_length and n + 1 < tails.size()) else head_index
		
		var to_idx = tails[n]
		if ((n > 1 and n - 1 < tails.size())):
			to_idx = tails[n - 1]
		elif n== 1:
			to_idx = head_index

		var from_dir = get_direction(from_idx, tails[n])
		var to_dir = get_direction(tails[n], to_idx)

		var is_straight = (from_dir.x == to_dir.x || from_dir.y == to_dir.y)
		var angle = 0.0
		var texture = null
		if n == tail_length:
			texture = tail_texture
			var tail_dir = get_direction(tails[n], tails[n - 1]) if n > 1 else get_direction(tails[n], head_index)
			if tail_dir == Vector2(0, -1):      # Up
				angle = deg_to_rad(0)
			elif tail_dir == Vector2(1, 0):     # Right
				angle = deg_to_rad(90)
			elif tail_dir == Vector2(0, 1):     # Down
				angle = deg_to_rad(180)
			elif tail_dir == Vector2(-1, 0):    # Left
				angle = deg_to_rad(270)
		elif is_straight:
			texture = body_straight_texture
			angle = get_texture_angle(from_dir, to_dir)
		else:
			var turn_dir = get_turn_direction(from_dir, to_dir)
			if turn_dir == "left":
				texture = body_turn_left_texture
			else:
				texture = body_turn_right_texture
			angle = get_turn_angle(from_dir, to_dir)

		var texture_size = texture.get_size()
		var scale = tile_size / texture_size.x  # assuming square textures
		draw_set_transform(center, angle, Vector2(scale, scale))
		draw_texture(texture, -texture_size / 2)
		draw_set_transform(Vector2(), 0.0)


	# Galva
	if head_index > 0 and head_index <= board.size():
		var head_tile = board[head_index - 1]
		var head_center = Vector2(head_tile.x + tile_size * 0.5, head_tile.y + tile_size * 0.5)

		draw_set_transform(head_center, head_rotation_radians, Vector2(head_scale, head_scale))
		draw_texture_rect(head_texture, Rect2(Vector2(-tile_size * 0.5, -tile_size * 0.5), Vector2(tile_size, tile_size)), false)
		draw_set_transform(Vector2(), 0.0)

	# Rezultatas
	draw_string(font, Vector2(20, 30), "Score: " + str(score))

	# Game Over tekstas
	if game_over:
		var text = "GAME OVER"
		var text_size = font.get_string_size(text)
		var center_pos = Vector2(vp_size.x / 2, vp_size.y / 2) - text_size / 2
		draw_string(font, center_pos, text)
		if not button_created:
			create_restart_button(center_pos + Vector2(0, text_size.y + 20))

func create_restart_button(position: Vector2):
	var button = Button.new()
	button.text = "Restart"
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.anchor_left = 0.5
	button.anchor_top = 0
	button.anchor_right = 0.5
	button.anchor_bottom = 0
	button.pivot_offset = Vector2(button.size.x / 2, 0)

	add_child(button)
	button.position = position
	button_created = true

	button.connect("pressed", Callable(self, "_on_restart_pressed"))


func _on_restart_pressed():
	get_tree().reload_current_scene()
	
func generate_board():
	board.clear()
	var vp_size = get_viewport_rect().size
	var side_len = min(vp_size.x, vp_size.y)
	tile_size = side_len / float(map_size)
	var board_start_x = (vp_size.x - side_len) * 0.5

	for i in range(map_size):
		for j in range(map_size):
			var x = board_start_x + float(j) * tile_size
			var y = float(i) * tile_size
			var tile_data = {
				"x": x,
				"y": y,
				"i": i + 1,
				"j": j + 1
			}
			board.append(tile_data)

func get_turn_direction(from_dir: Vector2, to_dir: Vector2) -> String:
	var cross = from_dir.x * to_dir.y - from_dir.y * to_dir.x
	return "left" if cross < 0 else "right"
	
func place_snake():
	head_index = random_int(1, board.size())
	tail_length = 0
	tails.clear()
	target_rotation_radians = deg_to_rad(90)
	head_rotation_radians = target_rotation_radians

func place_apple():
	var valid_spots = []
	for k in range(board.size()):
		var tile_id = k + 1
		if tile_id != head_index and not tails.has(tile_id):
			valid_spots.append(tile_id)
	if valid_spots.size() == 0:
		game_over = true
		return

	apple_index = valid_spots[randi() % valid_spots.size()]

func move_snake():
	if game_over:
		return

	var old_head = head_index
	var zero_based = head_index - 1
	var i = board[zero_based].i
	var j = board[zero_based].j

	match movement:
		1:
			if j == 1:
				game_over = true
				return
			j -= 1
		2:
			if j == map_size:
				game_over = true
				return
			j += 1
		3:
			if i == 1:
				game_over = true
				return
			i -= 1
		4:
			if i == map_size:
				game_over = true
				return
			i += 1

	var new_head_index = (i - 1) * map_size + j

	# Collision
	for t_idx in tails:
		if t_idx == new_head_index:
			game_over = true
			return

	# Shift tail
	if tail_length > 0:
		for n in range(tail_length, 1, -1):
			tails[n] = tails[n - 1]
		tails[1] = old_head

	# Apple
	if new_head_index == apple_index:
		tail_length += 1
		tails.resize(tail_length + 1)
		tails[tail_length] = old_head
		score += 1
		place_apple()
		head_scale = 1.3
		apples_in_tail.append(old_head)


	head_index = new_head_index

	# Move apples along the tail
	for n in range(apples_in_tail.size()):
		apples_in_tail[n] = move_apple_forward(apples_in_tail[n])

func move_apple_forward(segment):
	if segment in tails:
		var idx = tails.find(segment)
		if idx < tail_length:
			return tails[idx + 1]
	return segment

func get_direction(from_idx, to_idx):
	if from_idx == 0 or to_idx == 0:
		return Vector2(0, 0)
	var from_tile = board[from_idx - 1]
	var to_tile = board[to_idx - 1]
	return Vector2(to_tile.j - from_tile.j, to_tile.i - from_tile.i)

func get_texture_angle(from_dir: Vector2, to_dir: Vector2) -> float:
	var angle = 0.0
	# Horizontal (left-right)
	if from_dir.x == -1:
		angle = deg_to_rad(270)
	elif from_dir.x == 1:
		angle = deg_to_rad(90)
	# Vertical (up-down)
	elif from_dir.y == -1:
		angle = deg_to_rad(0)
	elif from_dir.y == 1:
		angle = deg_to_rad(180)
	return angle
	
func get_turn_angle(from_dir: Vector2, to_dir: Vector2) -> float:
	# All 4 possible corners
	if from_dir == Vector2(1, 0) and to_dir == Vector2(0, -1):  # Right to Up
		return deg_to_rad(90)
	elif from_dir == Vector2(0, -1) and to_dir == Vector2(1, 0):  # Up to Right
		return deg_to_rad(0)

	elif from_dir == Vector2(0, -1) and to_dir == Vector2(-1, 0):  # Up to Left
		return deg_to_rad(0)
	elif from_dir == Vector2(-1, 0) and to_dir == Vector2(0, -1):  # Left to Up
		return deg_to_rad(270)

	elif from_dir == Vector2(-1, 0) and to_dir == Vector2(0, 1):  # Left to Down
		return deg_to_rad(270)
	elif from_dir == Vector2(0, 1) and to_dir == Vector2(-1, 0):  # Down to Left
		return deg_to_rad(180)

	elif from_dir == Vector2(0, 1) and to_dir == Vector2(1, 0):  # Down to Right
		return deg_to_rad(180)
	elif from_dir == Vector2(1, 0) and to_dir == Vector2(0, 1):  # Right to Down
		return deg_to_rad(90)

	return 0.0  # Default fallback


func random_int(min_val: int, max_val: int) -> int:
	return randi() % (max_val - min_val + 1) + min_val


func _on_move_speed_slider_value_changed(value: float) -> void:
		move_interval = value
		get_viewport().set_input_as_handled() # optional, if you need to stop event propagation
		$MoveSpeedSlider.release_focus()
