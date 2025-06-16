extends Node2D

# ==============================================================================
# 							CONFIGURATION & CONSTANTS
# ==============================================================================

const MAP_SIZE := 20
var tile_size := 0.0
var move_interval := 0.15

# An enum makes the movement code much clearer than using numbers (1, 2, 3, 4)
enum Direction { NONE, LEFT, RIGHT, UP, DOWN }

# ==============================================================================
# 							NODE & SCENE REFERENCES
# ==============================================================================

@onready var pause_scene = preload("res://scenes/Pause.tscn")
var pause_instance = null
var eat_sound_player_node: AudioStreamPlayer

# ==============================================================================
# 							ASSET & RESOURCE LOADING
# ==============================================================================

var font: Font
var head_texture: Texture2D
var body_straight_texture: Texture2D
var body_turn_left_texture: Texture2D
var body_turn_right_texture: Texture2D
var tail_texture: Texture2D
var apple_texture: Texture2D
var background_texture: Texture2D
var eat_sound: AudioStreamRandomizer

# ==============================================================================
# 								GAME STATE
# ==============================================================================

var board := []
var game_over := false
var score := 0

# --- Snake State ---
var head_index := 0
var tail_segments: Array = []
var tail_length := 0
var current_direction: Direction = Direction.NONE
var next_direction: Direction = Direction.NONE

# --- Apple State ---
var apple_index := 0

# --- Timers & Animation ---
var timer := 0.0
const ROTATE_SPEED := 8.0
var head_rotation_radians := 0.0
var target_rotation_radians := 0.0
var head_scale := 1.0


# ==============================================================================
# 							GODOT LIFECYCLE FUNCTIONS
# ==============================================================================

func _ready():
	randomize()
	load_assets()
	
	# Create the sound player node programmatically
	eat_sound_player_node = AudioStreamPlayer.new()
	add_child(eat_sound_player_node)
	eat_sound_player_node.stream = eat_sound
	eat_sound_player_node.volume_db = -16
	
	start_game()

func _process(delta: float) -> void:
	if get_tree().paused:
		queue_redraw() # Keep drawing UI even when paused
		return
		
	if game_over:
		queue_redraw()
		return

	timer += delta
	if timer >= move_interval:
		timer = 0.0
		
		# Update direction only at the moment of movement
		if next_direction != Direction.NONE:
			current_direction = next_direction
			next_direction = Direction.NONE
		
		move_snake()
	
	# Smoothly interpolate rotation and scale for nice visual feedback
	head_rotation_radians = lerp_angle(head_rotation_radians, target_rotation_radians, delta * ROTATE_SPEED)
	head_scale = lerp(head_scale, 1.0, delta * 5.0)

	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	# --- Pause Input ---
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		return

	# --- Game Over Input ---
	if game_over:
		if event.is_action_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return
	
	# --- Player Movement Input (ignored if paused) ---
	if get_tree().paused:
		return
		
	if event.is_action_pressed("ui_left") and current_direction != Direction.RIGHT:
		next_direction = Direction.LEFT
	elif event.is_action_pressed("ui_right") and current_direction != Direction.LEFT:
		next_direction = Direction.RIGHT
	elif event.is_action_pressed("ui_up") and current_direction != Direction.DOWN:
		next_direction = Direction.UP
	elif event.is_action_pressed("ui_down") and current_direction != Direction.UP:
		next_direction = Direction.DOWN

func _draw():
	# --- Draw Tiled Background ---
	if background_texture:
		var vp_size = get_viewport_rect().size
		draw_texture_rect(background_texture, Rect2(0, 0, vp_size.x, vp_size.y), true)

	# --- Draw Game Board Background ---
	var vp_size = get_viewport_rect().size
	var side_len = min(vp_size.x, vp_size.y)
	var board_start_x = (vp_size.x - side_len) * 0.5
	draw_rect(Rect2(Vector2(board_start_x, 0), Vector2(side_len, side_len)), Color(0, 0, 0, 0.9))

	if game_over:
		# --- Draw Game Over Message (Consistent with Tetris) ---
		var game_over_string = "ŽAIDIMO PABAIGA"
		var restart_string = "Paspausk \"Enter\", kad pradėti iš naujo."

		var go_text_size = font.get_string_size(game_over_string, HORIZONTAL_ALIGNMENT_LEFT, -1, 40)
		var go_pos = Vector2(vp_size.x / 2 - go_text_size.x / 2, vp_size.y / 2 - 50)
		draw_string(font, go_pos, game_over_string, HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color.RED)
		
		var restart_text_size = font.get_string_size(restart_string, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
		var restart_pos = Vector2(vp_size.x / 2 - restart_text_size.x / 2, go_pos.y + 60)
		draw_string(font, restart_pos, restart_string, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	else:
		# --- Draw Apple, Snake Head & Body ---
		draw_apple()
		draw_snake_body()
		draw_snake_head()

	# --- Draw Score (Consistent with Tetris) ---
	var score_pos = Vector2(board_start_x + side_len + 10, 240)
	draw_string(font, score_pos, "TAŠKAI", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.WHITE)
	draw_string(font, score_pos + Vector2(0, 30), str(score), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.RED)


# ==============================================================================
# 								GAME LOGIC
# ==============================================================================

func move_snake():
	if game_over or current_direction == Direction.NONE:
		return

	var old_head_index = head_index
	var zero_based_index = head_index - 1
	
	if zero_based_index < 0 or zero_based_index >= board.size():
		game_over = true
		return
		
	var current_row = board[zero_based_index].i
	var current_col = board[zero_based_index].j

	# Calculate next position and update rotation
	match current_direction:
		Direction.LEFT:
			if current_col == 1: game_over = true; return
			current_col -= 1
			target_rotation_radians = deg_to_rad(270)
		Direction.RIGHT:
			if current_col == MAP_SIZE: game_over = true; return
			current_col += 1
			target_rotation_radians = deg_to_rad(90)
		Direction.UP:
			if current_row == 1: game_over = true; return
			current_row -= 1
			target_rotation_radians = deg_to_rad(0)
		Direction.DOWN:
			if current_row == MAP_SIZE: game_over = true; return
			current_row += 1
			target_rotation_radians = deg_to_rad(180)

	var new_head_index = (current_row - 1) * MAP_SIZE + current_col

	# Check for collision with self
	if tail_segments.has(new_head_index):
		game_over = true
		return

	# Update head position
	head_index = new_head_index
	
	# Update tail segments
	if tail_length > 0:
		tail_segments.push_front(old_head_index)
		while tail_segments.size() > tail_length:
			tail_segments.pop_back()

	# Check for apple collision
	if head_index == apple_index:
		eat_sound_player_node.play()
		tail_length += 1
		score += 10
		place_apple()
		head_scale = 1.4 # Visual feedback for eating

# ==============================================================================
# 								INITIALIZATION
# ==============================================================================

func load_assets():
	head_texture = preload("res://assets/snake/head.png")
	body_straight_texture = preload("res://assets/snake/body2.png")
	body_turn_left_texture = preload("res://assets/snake/body_turn2.png")
	body_turn_right_texture = preload("res://assets/snake/body_turn_right 2.png")
	tail_texture = preload("res://assets/snake/tail2.png")
	apple_texture = load("res://assets/snake/apple.png")
	background_texture = preload("res://assets/snake/jungle1.png")
	font = load("res://Game Bubble.ttf")
	
	eat_sound = AudioStreamRandomizer.new()
	eat_sound.add_stream(0, preload("res://sounds/snakeSounds/eatSound1.mp3"))
	eat_sound.add_stream(0, preload("res://sounds/snakeSounds/eatSound2.mp3"))
	eat_sound.add_stream(0, preload("res://sounds/snakeSounds/eatSound3.mp3"))
	eat_sound.add_stream(0, preload("res://sounds/snakeSounds/eatSound4.mp3"))

func start_game():
	score = 0
	tail_length = 0
	game_over = false
	timer = 0.0
	head_scale = 1.0
	
	generate_board()
	place_snake()
	place_apple()
	
	# Set initial direction
	current_direction = Direction.NONE
	next_direction = Direction.NONE
	target_rotation_radians = deg_to_rad(90)
	head_rotation_radians = target_rotation_radians

func generate_board():
	board.clear()
	var vp_size = get_viewport_rect().size
	var side_len = min(vp_size.x, vp_size.y)
	tile_size = side_len / float(MAP_SIZE)
	var board_start_x = (vp_size.x - side_len) * 0.5

	for i in range(MAP_SIZE):
		for j in range(MAP_SIZE):
			var x = board_start_x + float(j) * tile_size
			var y = float(i) * tile_size
			board.append({"x": x, "y": y, "i": i + 1, "j": j + 1})

func place_snake():
	tail_segments.clear()
	var start_row = int(MAP_SIZE / 2)
	var start_col = int(MAP_SIZE / 4) # Start further left for a better start
	head_index = (start_row - 1) * MAP_SIZE + start_col

func place_apple():
	var valid_spots = []
	var snake_parts = tail_segments.duplicate()
	snake_parts.append(head_index)

	for k in range(board.size()):
		var tile_id = k + 1
		if not snake_parts.has(tile_id):
			valid_spots.append(tile_id)
	
	if valid_spots.is_empty():
		game_over = true
		return

	apple_index = valid_spots[randi() % valid_spots.size()]

func toggle_pause():
	if pause_instance == null:
		pause_instance = pause_scene.instantiate()
		get_tree().get_root().add_child(pause_instance)
		get_tree().paused = true
		pause_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		get_tree().get_root().remove_child(pause_instance)
		pause_instance.queue_free()
		pause_instance = null
		get_tree().paused = false

# ==============================================================================
# 							DRAWING FUNCTIONS
# ==============================================================================

func draw_apple():
	if apple_index > 0 and apple_index <= board.size():
		var apple_tile = board[apple_index - 1]
		var center = Vector2(apple_tile.x + tile_size * 0.5, apple_tile.y + tile_size * 0.5)
		var rect = Rect2(-tile_size * 0.5, -tile_size * 0.5, tile_size, tile_size)
		draw_set_transform(center)
		draw_texture_rect(apple_texture, rect, false)
		draw_set_transform(Vector2.ZERO)

func draw_snake_head():
	if head_index > 0 and head_index <= board.size():
		var head_tile = board[head_index - 1]
		var head_center = Vector2(head_tile.x + tile_size * 0.5, head_tile.y + tile_size * 0.5)
		var rect = Rect2(-tile_size * 0.5, -tile_size * 0.5, tile_size, tile_size)
		
		draw_set_transform(head_center, head_rotation_radians, Vector2(head_scale, head_scale))
		draw_texture_rect(head_texture, rect, false)
		draw_set_transform(Vector2.ZERO)

func draw_snake_body():
	# This function uses the original rotation logic as requested.
	for i in range(tail_segments.size()):
		var segment_index = tail_segments[i]
		var tile = board[segment_index - 1]
		var center = Vector2(tile.x + tile_size * 0.5, tile.y + tile_size * 0.5)

		var texture_to_draw = null
		var rotation_angle = 0.0
		
		var prev_segment_idx = head_index if i == 0 else tail_segments[i - 1]
		
		# Logic for tail piece
		if i == tail_segments.size() - 1:
			texture_to_draw = tail_texture
			var tail_dir = get_direction(segment_index, prev_segment_idx)
			if tail_dir == Vector2(0, -1): rotation_angle = deg_to_rad(0)
			elif tail_dir == Vector2(1, 0): rotation_angle = deg_to_rad(90)
			elif tail_dir == Vector2(0, 1): rotation_angle = deg_to_rad(180)
			elif tail_dir == Vector2(-1, 0): rotation_angle = deg_to_rad(270)
			else: rotation_angle = target_rotation_radians
		# Logic for body pieces
		else:
			var next_segment_idx = tail_segments[i+1]
			
			var from_dir = get_direction(next_segment_idx, segment_index)
			var to_dir = get_direction(segment_index, prev_segment_idx)

			var is_straight = (from_dir.x == to_dir.x or from_dir.y == to_dir.y)

			if is_straight:
				texture_to_draw = body_straight_texture
				rotation_angle = get_texture_angle(from_dir, to_dir)
			else:
				var turn_type = get_turn_direction(from_dir, to_dir)
				texture_to_draw = body_turn_left_texture if turn_type == "left" else body_turn_right_texture
				rotation_angle = get_turn_angle(from_dir, to_dir)

		# Draw the calculated texture
		if texture_to_draw:
			var texture_size = texture_to_draw.get_size()
			var scale = tile_size / texture_size.x
			draw_set_transform(center, rotation_angle, Vector2(scale, scale))
			draw_texture(texture_to_draw, -texture_size / 2)
			draw_set_transform(Vector2.ZERO)


# ==============================================================================
# 							HELPER FUNCTIONS
# ==============================================================================

# Reverted to original get_direction logic
func get_direction(from_idx: int, to_idx: int) -> Vector2:
	if from_idx <= 0 or to_idx <= 0 or from_idx > board.size() or to_idx > board.size():
		return Vector2.ZERO
	var from_tile = board[from_idx - 1]
	var to_tile = board[to_idx - 1]
	return Vector2(to_tile.j - from_tile.j, to_tile.i - from_tile.i)

# Reverted to original get_turn_direction logic
func get_turn_direction(from_dir: Vector2, to_dir: Vector2) -> String:
	var cross = from_dir.x * to_dir.y - from_dir.y * to_dir.x
	return "left" if cross < 0 else "right"

# Reverted to original get_texture_angle logic for straight pieces
func get_texture_angle(from_dir: Vector2, to_dir: Vector2) -> float:
	var angle = 0.0
	if from_dir.x == -1: angle = deg_to_rad(270)
	elif from_dir.x == 1: angle = deg_to_rad(90)
	elif from_dir.y == -1: angle = deg_to_rad(0)
	elif from_dir.y == 1: angle = deg_to_rad(180)
	return angle

# Reverted to original get_turn_angle logic
func get_turn_angle(from_dir: Vector2, to_dir: Vector2) -> float:
	if from_dir == Vector2(1, 0) and to_dir == Vector2(0, -1): return deg_to_rad(90)
	elif from_dir == Vector2(0, -1) and to_dir == Vector2(1, 0): return deg_to_rad(0)
	elif from_dir == Vector2(0, -1) and to_dir == Vector2(-1, 0): return deg_to_rad(0)
	elif from_dir == Vector2(-1, 0) and to_dir == Vector2(0, -1): return deg_to_rad(270)
	elif from_dir == Vector2(-1, 0) and to_dir == Vector2(0, 1): return deg_to_rad(270)
	elif from_dir == Vector2(0, 1) and to_dir == Vector2(-1, 0): return deg_to_rad(180)
	elif from_dir == Vector2(0, 1) and to_dir == Vector2(1, 0): return deg_to_rad(180)
	elif from_dir == Vector2(1, 0) and to_dir == Vector2(0, 1): return deg_to_rad(90)
	return 0.0

func _on_move_speed_slider_value_changed(value: float) -> void:
	move_interval = value
	#The following lines can be useful if the slider is stealing focus.
	get_viewport().set_input_as_handled()
	if has_node("MoveSpeedSlider"):
		get_node("MoveSpeedSlider").release_focus()
