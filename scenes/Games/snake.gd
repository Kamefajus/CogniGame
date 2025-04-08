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

var timer = 0.0
var move_interval = 0.15
var score = 0


var head_rotation_radians = 0.0
var target_rotation_radians = 0.0
var rotate_speed = 8.0

var font: Font
var head_texture: Texture2D
var body_straight_texture: Texture2D
var body_turn_texture: Texture2D
var body_straight_fat_texture: Texture2D
var body_turn_fat_texture: Texture2D
var tail_texture: Texture2D

var eat_sound: AudioStreamPlayer
var head_scale = 1.0

var apples_in_tail: Array = []  # Kad sekam obuolį kūnu

func _ready():
	randomize()
	
	head_texture = preload("res://scenes/Games/head.png")
	body_straight_texture = preload("res://scenes/Games/body_straight.png")
	body_turn_texture = preload("res://scenes/Games/body_turn.png")
	body_straight_fat_texture = preload("res://scenes/Games/body_turn.png")#preload("res://scenes/Games/body_straight_fat.png")
	body_turn_fat_texture = preload("res://scenes/Games/body_turn.png")#preload("res://scenes/Games/body_turn_fat.png")
	tail_texture = preload("res://scenes/Games/tail.png")
	font = load("res://Game Bubble.ttf")

	generate_board()
	place_snake()
	place_apple()
	eat_sound = AudioStreamPlayer.new()
	eat_sound.stream = preload("res://scenes/Games/EatSound.wav")
	add_child(eat_sound)

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
		draw_circle(Vector2(a.x + tile_size * 0.5, a.y + tile_size * 0.5), tile_size * 0.5, Color.RED)

	# Kūnas
	# Kūnas
	for n in range(1, tail_length + 1):
		if n >= tails.size():
			continue

		var tile = board[tails[n] - 1]
		var center = Vector2(tile.x + tile_size * 0.5, tile.y + tile_size * 0.5)

		var from_idx = tails[n + 1] if (n < tail_length and n + 1 < tails.size()) else head_index
		var to_idx = tails[n - 1] if (n > 1 and n - 1 < tails.size()) else tails[n]

		var from_dir = get_direction(from_idx, tails[n])
		var to_dir = get_direction(tails[n], to_idx)

		var is_straight = (from_dir.x == to_dir.x || from_dir.y == to_dir.y)
		var use_fat = apples_in_tail.has(tails[n])

		var texture = null
		if is_straight:
			if use_fat:
				texture = body_straight_fat_texture
			else:
				texture = body_straight_texture
		else:
			if use_fat:
				texture = body_turn_fat_texture
			else:
				texture = body_turn_texture

		var angle = get_texture_angle(from_dir, to_dir)

		draw_set_transform(center, angle)
		draw_texture_rect(texture, Rect2(Vector2(-tile_size / 2, -tile_size / 2), Vector2(tile_size, tile_size)), false)
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

func place_snake():
	head_index = random_int(1, board.size())
	tail_length = 0
	tails.clear()
	movement = 2
	next_movement = 2
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
		eat_sound.play()
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

func get_texture_angle(from_dir, to_dir):
	var sum_dir = from_dir + to_dir
	if sum_dir == Vector2(0, -2):
		return deg_to_rad(0)
	elif sum_dir == Vector2(2, 0):
		return deg_to_rad(90)
	elif sum_dir == Vector2(0, 2):
		return deg_to_rad(180)
	elif sum_dir == Vector2(-2, 0):
		return deg_to_rad(270)
	elif (from_dir.x == to_dir.y and from_dir.y == -to_dir.x):
		return deg_to_rad(90)
	elif (from_dir.x == -to_dir.y and from_dir.y == to_dir.x):
		return deg_to_rad(270)
	elif (from_dir.x == from_dir.y and to_dir.x == to_dir.y):
		return deg_to_rad(0)
	else:
		return deg_to_rad(180)

func random_int(min_val: int, max_val: int) -> int:
	return randi() % (max_val - min_val + 1) + min_val
