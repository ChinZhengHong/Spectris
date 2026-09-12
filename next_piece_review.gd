extends Node2D

const CELL_SIZE = 24

@onready var current_piece = get_node("../CurrentPiece")
@onready var board = get_node("../Board")

func _process(_delta):
	queue_redraw()

func _draw():
	if current_piece.next_offsets.is_empty():
		return

	for i in range(current_piece.next_offsets.size()):
		var offset = current_piece.next_offsets[i]
		var color_id = current_piece.next_colors[i]
		var rect = Rect2(offset.x * CELL_SIZE, offset.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
		draw_rect(rect, board.get_color_for_id(color_id))
		draw_rect(rect, Color.BLACK, false, 1.0)
