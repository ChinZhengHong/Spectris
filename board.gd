extends Node2D
# constant
const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 32

# color ID for every grid
var grid = []
var white_rows_count = 0
var max_white_rows = GRID_HEIGHT / 2

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

	grid.remove_at(y)
	var new_row = []
	for x in range(GRID_WIDTH):
		new_row.append(-1)
	grid.insert(0, new_row)
	
	for x in range(GRID_WIDTH):
		if row_colors[x] != -1:
			_spawn_clear_particles(x, y, get_color_for_id(row_colors[x]))

func check_and_clear_lines():
	var y = GRID_HEIGHT - 1
	while y >= 0:
		if _is_row_full(y):
			_clear_row(y)
		else:
			y -= 1
	
	if game_manager.should_spawn_white_block():
		spawn_white_row()

func _spawn_clear_particles(grid_x: int, grid_y: int, color: Color):
	var particles = CPUParticles2D.new()
	add_child(particles)
	particles.position = Vector2(grid_x * CELL_SIZE + CELL_SIZE / 2, grid_y * CELL_SIZE + CELL_SIZE / 2)
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 8
	particles.lifetime = 0.5
	particles.explosiveness = 1.0
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 150.0
	particles.gravity = Vector2(0, 300)
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = color
	particles.emitting = true
	get_tree().create_timer(particles.lifetime + 0.1).timeout.connect(particles.queue_free)

func spawn_white_row():
	if white_rows_count >= max_white_rows:
		return

	if _get_player_stack_height() >= GRID_HEIGHT / 2:
		return

	var new_row = []
	var empty_index = randi() % GRID_WIDTH
	for x in range(GRID_WIDTH):
		if x == empty_index:
			new_row.append(-1)
		else:
			new_row.append(7)

	grid.remove_at(0)
	grid.append(new_row)
	white_rows_count += 1
	queue_redraw()

func _get_player_stack_height() -> int:
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid[y][x] != -1 and grid[y][x] != 7:
				return GRID_HEIGHT - y
	return 0
