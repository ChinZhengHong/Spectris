extends Node2D

const PieceData = preload("res://piece_data.gd")

const CELL_SIZE = 32

# save current grid status
var current_type = PieceData.PieceType.T
var grid_position = Vector2i(4, 0)
var block_offsets = []

func _ready():
	_spawn_piece()
	
func _spawn_piece():
	var types = PieceData.PieceType.values()
	current_type = types[randi() % types.size()]
	block_offsets = PieceData.SHAPES[current_type]
	grid_position = Vector2i(4, 0)
	queue_redraw()
	
func _draw():
	for offset in block_offsets:
		var cell = grid_position + offset
		var rect = Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
		draw_rect(rect, Color.CYAN)
		
# input
func _unhandled_input(event):
	if event.is_action_pressed("ui_left"):
		grid_position.x -= 1
		queue_redraw()
	elif event.is_action_pressed("ui_right"):
		grid_position.x += 1
		queue_redraw()
	elif event.is_action_pressed("ui_down"):
		grid_position.y += 1
		queue_redraw()
