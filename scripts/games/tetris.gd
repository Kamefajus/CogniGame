extends Node2D

@onready var pause_scene = preload("res://scenes/Pause.tscn")
var pause = null

const GRID_WIDTH := 10
const GRID_HEIGHT := 20
const TILE_SIZE := 24

@onready var move_Sound = $move_Sound
@onready var GameOver_Sound = $GameOver_Sound
@onready var Falling_Sound = $falling_Sound
@onready var rotate_Sound = $rotate_Sound


const SHAPES = {
	"I": [[Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)]],
	"O": [[Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 1)]],
	"T": [[Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)]],
	"S": [[Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1)]],
	"Z": [[Vector2(-1, 0), Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)]],
	"J": [[Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]],
	"L": [[Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1)]]
}

const COLORS = {
	"I": Color(0.0, 0.74, 0.83),  # Cyan
	"O": Color(1.0, 0.92, 0.23), # Yellow
	"T": Color(0.61, 0.15, 0.69), # Purple
	"S": Color(0.3, 0.69, 0.31),  # Green
	"Z": Color(0.96, 0.26, 0.21), # Red
	"J": Color(0.13, 0.59, 0.95), # Blue
	"L": Color(1.0, 0.6, 0.0)     # Orange
}

# --- Game State Variables ---
var board := []
var current_piece := []
var current_type := ""
var current_position := Vector2(5, 0)
var current_color := Color.WHITE

# --- Next Piece Variables ---
var next_type := ""
var next_piece := []
var next_color := Color.WHITE

# --- Timing and Control ---
var drop_timer := 0.0
var drop_interval := 0.5
var initial_drop_interval := 0.5
var soft_drop := false
var game_over := false

# --- Score and Difficulty Variables ---
var score := 0
var lines_cleared := 0
var level := 1
const LINES_PER_LEVEL := 10
const SCORE_POINTS = { 1: 40, 2: 100, 3: 300, 4: 1200 }

# --- Custom Font Variable ---
var custom_font: Font

func _ready():
	# --- NEW: Load the custom font ---
	# Make sure the path is correct to your font file in the FileSystem dock
	custom_font = load("res://Game Bubble.ttf")
	
	new_board()
	generate_next_piece()
	spawn_piece()

func new_board():
	board.resize(GRID_HEIGHT)
	for y in range(GRID_HEIGHT):
		board[y] = []
		board[y].resize(GRID_WIDTH)
		board[y].fill(null)

# --- Piece Spawning and Management ---

func spawn_piece():
	current_type = next_type
	current_piece = next_piece
	current_color = next_color
	current_position = Vector2(5, 0)
	
	generate_next_piece()
	
	if not is_valid_position(current_position, current_piece):
		game_over = true

func generate_next_piece():
	var types = SHAPES.keys()
	next_type = types[randi() % types.size()]
	next_piece = SHAPES[next_type][0]
	next_color = COLORS[next_type]

# --- Game Loop ---

func _process(delta):
	if get_tree().paused:
		return
	if game_over:
		queue_redraw()
		return
		
	drop_timer += delta
	if drop_timer >= (drop_interval if not soft_drop else 0.05):
		drop_timer = 0
		if not move(Vector2(0, 1)):
			lock_piece()
			clear_lines()
			spawn_piece()
			
	queue_redraw()

# --- Player Input ---

func _input(event):
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
	if game_over:
		if event.is_action_pressed("ui_accept"):
			get_tree().reload_current_scene()
		return
		
	if event.is_action_pressed("ui_left"):
		move(Vector2(-1, 0))
		move_Sound.play()
	elif event.is_action_pressed("ui_right"):
		move(Vector2(1, 0))
		move_Sound.play()
	elif event.is_action_pressed("ui_down"):
		soft_drop = true
		Falling_Sound.play()
	elif event.is_action_released("ui_down"):
		soft_drop = false
		Falling_Sound.stop() 
	elif event.is_action_pressed("ui_up"):
		rotate_piece()
		rotate_Sound.play()
	elif event.is_action_pressed("ui_select"):
		hard_drop()

# --- Piece Movement and Logic ---

func hard_drop():
	while move(Vector2(0, 1)):
		score += 2
	lock_piece()
	clear_lines()
	spawn_piece()

func move(dir: Vector2) -> bool:
	var new_pos = current_position + dir
	if is_valid_position(new_pos, current_piece):
		current_position = new_pos
		return true
	return false

func is_valid_position(pos: Vector2, shape: Array) -> bool:
	for block in shape:
		var x = int(pos.x + block.x)
		var y = int(pos.y + block.y)
		if x < 0 or x >= GRID_WIDTH or y >= GRID_HEIGHT:
			return false
		if y >= 0 and board[y][x] != null:
			return false
	return true

func lock_piece():
	for block in current_piece:
		var x = int(current_position.x + block.x)
		var y = int(current_position.y + block.y)
		if y >= 0 and y < GRID_HEIGHT:
			board[y][x] = current_color

func rotate_piece():
	if current_type == "O":
		return
	var new_shape := []
	for block in current_piece:
		new_shape.append(Vector2(-block.y, block.x))
	
	var kick_tests = [Vector2(0,0), Vector2(1,0), Vector2(-1,0), Vector2(2,0), Vector2(-2,0), Vector2(0,-1)]
	for kick in kick_tests:
		if is_valid_position(current_position + kick, new_shape):
			current_position += kick
			current_piece = new_shape
			return

# --- Scoring and Leveling ---

func clear_lines():
	var lines_to_clear = []
	for y in range(GRID_HEIGHT):
		if not board[y].has(null):
			lines_to_clear.append(y)
	
	if lines_to_clear.size() > 0:
		for y in lines_to_clear:
			board.remove_at(y)
			
		for _i in range(lines_to_clear.size()):
			var new_line = []
			new_line.resize(GRID_WIDTH)
			new_line.fill(null)
			board.insert(0, new_line)
			
		update_score_and_level(lines_to_clear.size())

func update_score_and_level(cleared_count: int):
	score += SCORE_POINTS[cleared_count] * level
	
	lines_cleared += cleared_count
	if lines_cleared >= level * LINES_PER_LEVEL:
		level += 1
		drop_interval = max(0.08, initial_drop_interval - (level - 1) * 0.04)
		print("Level up! New interval: ", drop_interval)

# --- Drawing ---

func _draw():
	var screen_size = get_viewport_rect().size
	var grid_pixel_size = Vector2(GRID_WIDTH, GRID_HEIGHT) * TILE_SIZE
	var start_pos = (screen_size - grid_pixel_size) / 2
	
	draw_rect(Rect2(start_pos, grid_pixel_size), Color(0.1, 0.1, 0.1, 0.8))
	
	for i in range(GRID_WIDTH + 1):
		draw_line(start_pos + Vector2(i * TILE_SIZE, 0), start_pos + Vector2(i * TILE_SIZE, grid_pixel_size.y), Color8(255, 255, 255, 50), 1)
	for i in range(GRID_HEIGHT + 1):
		draw_line(start_pos + Vector2(0, i * TILE_SIZE), start_pos + Vector2(grid_pixel_size.x, i * TILE_SIZE), Color8(255, 255, 255, 50), 1)

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if board[y][x] != null:
				var block_pos = Vector2(x, y) * TILE_SIZE + start_pos
				draw_rect(Rect2(block_pos, Vector2(TILE_SIZE, TILE_SIZE)), board[y][x], )
				draw_rect(Rect2(block_pos, Vector2(TILE_SIZE, TILE_SIZE)), Color.BLACK, false, 1)

	for block in current_piece:
		var pos = (current_position + block) * TILE_SIZE + start_pos
		draw_rect(Rect2(pos, Vector2(TILE_SIZE, TILE_SIZE)), current_color)
		draw_rect(Rect2(pos, Vector2(TILE_SIZE, TILE_SIZE)), Color.BLACK, false, 1)
		
	# --- UI Drawing (Score, Level, Next Piece) ---
	# --- MODIFIED: Pass custom_font to draw_string ---
	
	# Draw Score and Level
	var score_pos = Vector2(start_pos.x + grid_pixel_size.x + 20, start_pos.y + 40)
	draw_string(custom_font, score_pos, "SCORE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	draw_string(custom_font, score_pos + Vector2(0, 30), str(score), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.YELLOW)
	
	var level_pos = Vector2(start_pos.x + grid_pixel_size.x + 20, start_pos.y + 100)
	draw_string(custom_font, level_pos, "LEVEL", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	draw_string(custom_font, level_pos + Vector2(0, 30), str(level), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.YELLOW)
	
	# Draw Next Piece Preview
	var next_piece_pos = Vector2(start_pos.x + grid_pixel_size.x + 20, start_pos.y + 160)
	draw_string(custom_font, next_piece_pos, "NEXT", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	for block in next_piece:
		var pos = block * TILE_SIZE + next_piece_pos + Vector2(40, 60)
		draw_rect(Rect2(pos, Vector2(TILE_SIZE, TILE_SIZE)), next_color)
		draw_rect(Rect2(pos, Vector2(TILE_SIZE, TILE_SIZE)), Color.BLACK, false, 1)

	# Draw Game Over message
	if game_over:
		var game_over_pos = Vector2(screen_size.x / 2 - 100, screen_size.y / 2 - 50)
		# You can also change font size for specific text
		draw_string(custom_font, game_over_pos, "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color.RED)
		draw_string(custom_font, game_over_pos + Vector2(10, 50), "Press Enter to Restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
