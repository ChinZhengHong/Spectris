extends Node2D

const PieceData = preload("res://piece_data.gd")

const CELL_SIZE = 32

# save current grid status
var current_type = PieceData.PieceType.T
var grid_position = Vector2i(4, 0)
var block_offsets = []
var current_color_id = 0
var is_game_over = false
@onready var board = get_node("../Board")

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

# rotate
func _get_rotated_offsets(offsets: Array) -> Array:
	var rotated = []
	for offset in offsets:
		rotated.append(Vector2i(-offset.y, offset.x))
	return rotated

func _ready():
	_spawn_piece()
	
func _spawn_piece():
	var types = PieceData.PieceType.values()
	current_type = types[randi() % types.size()]
	block_offsets = PieceData.SHAPES[current_type]
	grid_position = Vector2i(4, 0)

	if not _can_move(block_offsets, grid_position):
		is_game_over = true
		print("Game Over")
		return

	queue_redraw()
	
func _draw():
	for offset in block_offsets:
		var cell = grid_position + offset
		var rect = Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
		draw_rect(rect, board.get_color_for_id(current_color_id))
		
# input
func _unhandled_input(event):
	if is_game_over:
		return
	if event.is_action_pressed("ui_left"):
		var new_pos = grid_position + Vector2i(-1, 0)
		if _can_move(block_offsets, new_pos):
			grid_position = new_pos
			queue_redraw()
	elif event.is_action_pressed("ui_right"):
		var new_pos = grid_position + Vector2i(1, 0)
		if _can_move(block_offsets, new_pos):
			grid_position = new_pos
			queue_redraw()
	elif event.is_action_pressed("ui_down"):
		var new_pos = grid_position + Vector2i(0, 1)
		if _can_move(block_offsets, new_pos):
			grid_position = new_pos
			queue_redraw()
			
	elif event.is_action_pressed("ui_up"):
		if current_type != PieceData.PieceType.O:
			var new_offsets = _get_rotated_offsets(block_offsets)
			if _can_move(new_offsets, grid_position):
				block_offsets = new_offsets
				queue_redraw()


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
	for offset in block_offsets:
		var cell = grid_position + offset
		board.grid[cell.y][cell.x] = current_color_id
	board.check_and_clear_lines()
	board.queue_redraw()
