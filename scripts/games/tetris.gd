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
	"I": Color(0.0, 0.74, 0.83),   # Cyan
	"O": Color(1.0, 0.92, 0.23),   # Yellow
	"T": Color(0.61, 0.15, 0.69),  # Purple
	"S": Color(0.3, 0.69, 0.31),   # Green
	"Z": Color(0.96, 0.26, 0.21),  # Red
	"J": Color(0.13, 0.59, 0.95),  # Blue
	"L": Color(1.0, 0.6, 0.0)      # Orange
}

var board := []
var current_piece := []
var current_type := ""
var current_position := Vector2(5, 0)
var current_color := Color.WHITE

var drop_timer := 0.0
var drop_interval := 0.5
var soft_drop := false
var game_over := false

func _ready():
	new_board()
	spawn_piece()

func new_board():
	board.resize(GRID_HEIGHT)
	for y in range(GRID_HEIGHT):
		board[y] = []
		board[y].resize(GRID_WIDTH)
		for x in range(GRID_WIDTH):
			board[y][x] = null

func spawn_piece():
	var types = SHAPES.keys()
	current_type = types[randi() % types.size()]
	current_piece = SHAPES[current_type][0]
	current_position = Vector2(5, 0)
	current_color = COLORS[current_type]
	if not is_valid_position(current_position, current_piece):
		game_over = true

func _process(delta):
	if get_tree().paused:
		return
	if game_over:
		return
	drop_timer += delta
	if drop_timer >= (drop_interval if not soft_drop else 0.05):
		drop_timer = 0
		if not move(Vector2(0, 1)):
			lock_piece()
			clear_lines()
			spawn_piece()
	queue_redraw()

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

func hard_drop():
	while move(Vector2(0, 1)):
		pass
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
		if x < 0 or x >= GRID_WIDTH or y < 0 or y >= GRID_HEIGHT:
			return false
		if board[y][x] != null:
			return false
	return true

func lock_piece():
	for block in current_piece:
		var x = int(current_position.x + block.x)
		var y = int(current_position.y + block.y)
		if y >= 0 and y < GRID_HEIGHT:
			board[y][x] = current_color

func clear_lines():
	var new_board := []
	for y in range(GRID_HEIGHT):
		if board[y].has(null):
			new_board.append(board[y])
	for i in range(GRID_HEIGHT - new_board.size()):
		var empty_line := []
		empty_line.resize(GRID_WIDTH)
		for x in range(GRID_WIDTH):
			empty_line[x] = null
		new_board.insert(0, empty_line)
	board = new_board

func rotate_piece():
	if current_type == "O":
		return
	var new_shape := []
	for block in current_piece:
		new_shape.append(Vector2(-block.y, block.x))
	if is_valid_position(current_position, new_shape):
		current_piece = new_shape

func _draw():
	var start_x = (get_viewport_rect().size.x - GRID_WIDTH * TILE_SIZE) / 2
	var start_y = (get_viewport_rect().size.y - GRID_HEIGHT * TILE_SIZE) / 2
	draw_rect(Rect2(Vector2(start_x, start_y), Vector2(GRID_WIDTH, GRID_HEIGHT) * TILE_SIZE), Color(0.7, 0.7, 0.7), false)

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if board[y][x] != null:
				draw_rect(Rect2(Vector2(x, y) * TILE_SIZE + Vector2(start_x, start_y), Vector2(TILE_SIZE, TILE_SIZE)), board[y][x])

	for block in current_piece:
		var pos = (current_position + block) * TILE_SIZE + Vector2(start_x, start_y)
		draw_rect(Rect2(pos, Vector2(TILE_SIZE, TILE_SIZE)), current_color)

	if game_over:
		pass
		#draw_string(get_font("font"), Vector2(start_x + 20, start_y + GRID_HEIGHT * TILE_SIZE / 2), "GAME OVER", Color(1, 0, 0))
