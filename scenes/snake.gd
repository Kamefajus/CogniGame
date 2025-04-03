extends Node2D

var map_size = 20
var tile_size = 0
var board = []
var head_index = 0  # 1-based
var tails: Array = []
var tail_length = 0

var apple_index = 0
var game_over = false
var movement = 0  # 1=left, 2=right, 3=up, 4=down
var timer = 0.0
var move_interval = 0.15
var score = 0

# If you want to display text, define or preload a font resource
# For example: 
# onready var default_font: Font = preload("res://path/to/MyFont.tres")

func _ready():
	randomize()  # seed the random generator
	generate_board()
	place_snake()
	place_apple()

func _process(delta: float) -> void:
	if game_over:
		return
	timer += delta
	if timer >= move_interval:
		do_movement(movement)
		timer = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left") and movement != 2:
		movement = 1
		do_movement(movement)
	elif event.is_action_pressed("ui_right") and movement != 1:
		movement = 2
		do_movement(movement)
	elif event.is_action_pressed("ui_up") and movement != 4:
		movement = 3
		do_movement(movement)
	elif event.is_action_pressed("ui_down") and movement != 3:
		movement = 4
		do_movement(movement)

func _draw():
	# Draw the board outline (white)
	var vp_size = get_viewport_rect().size
	var side_len = vp_size.y
	var board_start_x = (vp_size.x - side_len) * 0.5
	draw_rect(Rect2(Vector2(board_start_x, 0), Vector2(side_len, side_len)), Color.WHITE, false)

	# Draw apple (if valid index)
	if apple_index > 0 and apple_index <= board.size():
		var a = board[apple_index - 1]
		draw_circle(Vector2(a.x + tile_size * 0.5, a.y + tile_size * 0.5), tile_size * 0.5, Color.RED)

	# Draw the snake’s head
	if head_index > 0 and head_index <= board.size():
		var head_tile = board[head_index - 1]
		draw_rect(Rect2(head_tile.x + 1, head_tile.y + 1, tile_size - 2, tile_size - 2), Color.GREEN)

	# Draw the tail
	for i in range(1, tail_length + 1):
		var tail_tile_index = tails[i]
		if tail_tile_index > 0 and tail_tile_index <= board.size():
			var t = board[tail_tile_index - 1]
			draw_rect(Rect2(t.x + 1, t.y + 1, tile_size - 2, tile_size - 2), Color.GREEN)

	# If game over, optionally draw text
	if game_over:
		# If you have a loaded font, you can do something like:
		# draw_string(default_font, Vector2(50, 50), "GAME OVER! Score: %d" % score, 24.0, Color.WHITE)
		# Otherwise, remove or comment this out:
		pass

# ------------------------------------------------------------------------
# HELPER FUNCTIONS
# ------------------------------------------------------------------------

func generate_board():
	board.clear()
	var vp_size = get_viewport_rect().size
	var side_len = vp_size.y
	tile_size = side_len / float(map_size)
	var board_start_x = (vp_size.x - side_len) * 0.5

	for i in range(map_size):       # i=0..map_size-1
		for j in range(map_size):   # j=0..map_size-1
			var x = board_start_x + float(j) * tile_size
			var y = float(i) * tile_size
			var tile_data = {
				"x": x,
				"y": y,
				"i": i + 1,    # store 1-based for convenience
				"j": j + 1
			}
			board.append(tile_data)

func place_snake():
	head_index = random_int(1, board.size())
	tail_length = 0
	tails.clear()

func place_apple():
	var valid_spots = []
	for k in range(board.size()):
		var tile_id = k + 1  # 1-based
		if tile_id != head_index and not tails.has(tile_id):
			valid_spots.append(tile_id)
	if valid_spots.size() == 0:
		game_over = true
		return

	var pick = valid_spots[randi() % valid_spots.size()]
	apple_index = pick

func do_movement(move: int):
	if game_over:
		return

	var old_head = head_index
	var zero_based = head_index - 1
	if zero_based < 0 or zero_based >= board.size():
		return
	
	var i = board[zero_based].i
	var j = board[zero_based].j

	# 1=left, 2=right, 3=up, 4=down
	match move:
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
		_:
			# No movement
			return

	var new_head_index = (i - 1) * map_size + j

	# Tail collision check
	for t_idx in tails:
		if t_idx == new_head_index:
			game_over = true
			return

	# Shift tail positions
	if tail_length > 0:
		for n in range(tail_length, 1, -1):
			tails[n] = tails[n - 1]
		tails[1] = old_head

	# Apple check
	if new_head_index == apple_index:
		tail_length += 1
		tails.resize(tail_length + 1)
		tails[tail_length] = old_head
		score += 1
		place_apple()

	head_index = new_head_index

	# Final collision re-check (rare edge cases)
	for t_idx in tails:
		if t_idx == head_index:
			game_over = true
			return
	self.queue_redraw()

# If you want a quick integer random function:
func random_int(min_val: int, max_val: int) -> int:
	return randi() % (max_val - min_val + 1) + min_val
