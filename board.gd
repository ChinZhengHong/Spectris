extends Node2D
# constant
const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 32

# color ID for every grid
var grid = []

@onready var game_manager = get_node("../GameManager")

func _ready():
	_init_grid()
	
func _init_grid():
	grid.clear()
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			row.append(-1) #initial value = -1, mean it is empty
		grid.append(row)
		
# color
func get_color_for_id(id: int) -> Color:
	match id:
		0: return Color.RED
		1: return Color.ORANGE
		2: return Color.YELLOW
		3: return Color.GREEN
		4: return Color.BLUE
		5: return Color(0.29, 0, 0.51)
		6: return Color(0.58, 0, 0.83)
		7: return Color.WHITE
		_: return Color.GRAY

# drawing line
func _draw():
	for x in range(GRID_WIDTH + 1):
		var start = Vector2(x * CELL_SIZE, 0)
		var end = Vector2(x * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
		draw_line(start, end, Color.GRAY, 1.0)
	
	for y in range (GRID_HEIGHT + 1):
		var start = Vector2(0, y * CELL_SIZE)
		var end = Vector2(GRID_WIDTH * CELL_SIZE, y * CELL_SIZE)
		draw_line(start, end, Color.GRAY, 1.0)
		
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid[y][x] != -1:
				var rect = Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
				draw_rect(rect, get_color_for_id(grid[y][x]))
				draw_rect(rect, Color.BLACK, false, 1.0)

# check the row
func _is_row_full(y: int) -> bool:
	for x in range(GRID_WIDTH):
		if grid[y][x] == -1:
			return false
	return true
	
# clear row
func _clear_row(y: int):
	var row_colors = grid[y].duplicate()
	game_manager.register_line_clear(row_colors)
	
	if y + 1 < GRID_HEIGHT:
		for x in range(GRID_WIDTH):
			if grid[y + 1][x] == 7:
				grid[y + 1][x] = -1

	grid.remove_at(y)
	var new_row = []
	for x in range(GRID_WIDTH):
		new_row.append(-1)
	grid.insert(0, new_row)
	

func check_and_clear_lines():
	var y = GRID_HEIGHT - 1
	while y >= 0:
		if _is_row_full(y):
			_clear_row(y)
		else:
			y -= 1
