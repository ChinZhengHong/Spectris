extends Node2D

const PieceData = preload("res://piece_data.gd")

const CELL_SIZE = 32

# save current grid status
var current_type = PieceData.PieceType.T
var grid_position = Vector2i(4, 0)
var block_offsets = []
var block_colors = []
var next_type = PieceData.PieceType.T
var next_offsets = []
var next_colors = []
var move_direction = 0
var das_timer = 0.0
var arr_timer = 0.0
var down_arr_timer = 0.0
var down_pressed_last_frame = false
var down_das_timer = 0.0
const DAS_DELAY = 0.15
const ARR_RATE = 0.05
var is_game_over = false
@onready var board = get_node("../Board")
@onready var game_manager = get_node("../GameManager")
@onready var timer = $Timer

func _can_move(offsets: Array, pos: Vector2i) -> bool:
	for offset in offsets:
		var cell = pos + offset
		if cell.x < 0 or cell.x >= board.GRID_WIDTH:
			return false
		if cell.y >= board.GRID_HEIGHT:
			return false
		if cell.y >= 0 and board.grid[cell.y][cell.x] != -1:
			return false
	return true

func _try_move(direction: Vector2i):
	var new_pos = grid_position + direction
	if _can_move(block_offsets, new_pos):
		grid_position = new_pos
		queue_redraw()
		
func _process(delta):
	if is_game_over:
		return

	if Input.is_action_pressed("ui_left"):
		if move_direction != -1:
			move_direction = -1
			das_timer = 0.0
			_try_move(Vector2i(-1, 0))
		else:
			das_timer += delta
			if das_timer >= DAS_DELAY:
				arr_timer += delta
				if arr_timer >= ARR_RATE:
					arr_timer = 0.0
					_try_move(Vector2i(-1, 0))
	elif Input.is_action_pressed("ui_right"):
		if move_direction != 1:
			move_direction = 1
			das_timer = 0.0
			_try_move(Vector2i(1, 0))
		else:
			das_timer += delta
			if das_timer >= DAS_DELAY:
				arr_timer += delta
				if arr_timer >= ARR_RATE:
					arr_timer = 0.0
					_try_move(Vector2i(1, 0))
	else:
		move_direction = 0
		das_timer = 0.0
		arr_timer = 0.0
		
	if Input.is_action_pressed("ui_down"):
		if not down_pressed_last_frame:
			down_pressed_last_frame = true
			down_das_timer = 0.0
			_try_move(Vector2i(0, 1))
		else:
			down_das_timer += delta
			if down_das_timer >= DAS_DELAY:
				down_arr_timer += delta
				if down_arr_timer >= ARR_RATE:
					down_arr_timer = 0.0
					_try_move(Vector2i(0, 1))
	else:
		down_pressed_last_frame = false
		down_das_timer = 0.0
		down_arr_timer = 0.0

# rotate
func _get_rotated_offsets(offsets: Array) -> Array:
	var rotated = []
	for offset in offsets:
		rotated.append(Vector2i(-offset.y, offset.x))
	return rotated


func _ready():
	_spawn_piece()
	
func _generate_random_piece():
	var types = PieceData.PieceType.values()
	var type = types[randi() % types.size()]
	var offsets = PieceData.SHAPES[type]

	var base_color = game_manager.get_random_piece_color()
	var colors = []
	for i in range(offsets.size()):
		colors.append(base_color)

	if game_manager.should_spawn_white_block():
		var white_index = randi() % colors.size()
		colors[white_index] = 7

	return {"type": type, "offsets": offsets, "colors": colors}
	
func _spawn_piece():
	if next_offsets.is_empty():
		var first = _generate_random_piece()
		current_type = first.type
		block_offsets = first.offsets
		block_colors = first.colors
	else:
		current_type = next_type
		block_offsets = next_offsets
		block_colors = next_colors

	grid_position = Vector2i(4, 1)

	var upcoming = _generate_random_piece()
	next_type = upcoming.type
	next_offsets = upcoming.offsets
	next_colors = upcoming.colors

	if not _can_move(block_offsets, grid_position):
		is_game_over = true
		print("Game Over")
		return

	queue_redraw()

func _draw():
	for i in range(block_offsets.size()):
		var cell = grid_position + block_offsets[i]
		var rect = Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
		draw_rect(rect, board.get_color_for_id(block_colors[i]))
		draw_rect(rect, Color.BLACK, false, 1.0)
		
# input
func _unhandled_input(event):
	if is_game_over:
		return
	if event.is_action_pressed("ui_down"):
		_try_move(Vector2i(0,1))
			
	elif event.is_action_pressed("ui_up"):
		if current_type != PieceData.PieceType.O:
			var new_offsets = _get_rotated_offsets(block_offsets)
			var kick_tests = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(2, 0)]
			for kick in kick_tests:
				var test_pos = grid_position + kick
				if _can_move(new_offsets, test_pos):
					block_offsets = new_offsets
					grid_position = test_pos
					queue_redraw()
					break


func _on_timer_timeout() -> void:
	if is_game_over:
		return
	var new_pos = grid_position + Vector2i(0, 1)
	if _can_move(block_offsets, new_pos):
		grid_position = new_pos
		queue_redraw()
	else:
		_lock_piece()
		_spawn_piece()
		
func _lock_piece():
	for i in range(block_offsets.size()):
		var cell = grid_position + block_offsets[i]
		board.grid[cell.y][cell.x] = block_colors[i]
	board.check_and_clear_lines()
	board.queue_redraw()
	timer.wait_time = game_manager.get_current_fall_time()
