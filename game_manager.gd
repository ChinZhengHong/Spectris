extends Node

const TOTAL_SPECTRUM_COLORS = 7
const LINES_TO_UNLOCK = [10, 15, 20, 25, 30, 35, 40]
const BASE_FALL_TIME = 1.0
const FALL_TIME_DECREASE = 0.1
const MIN_FALL_TIME = 0.2
const TIME_DECREASE_INTERVAL = 30.0
const TIME_DECREASE_AMOUNT = 0.05
var elapsed_time = 0.0
const SCORE_PER_WHITE_BLOCK = 50
var score_since_last_white = 0
@onready var score_label = get_node("../UI/ScoreLabel")
@onready var color_label = get_node("../UI/ColorLabel")
@onready var progress_label = get_node("../UI/ProgressLabel")
var score = 0
var unlocked_color_index = 0
var lines_cleared_for_current_color = 0


func get_current_target_color() -> int:
	return unlocked_color_index

func _check_unlock_next_color():
	var threshold = LINES_TO_UNLOCK[unlocked_color_index]
	if lines_cleared_for_current_color >= threshold:
		if unlocked_color_index < TOTAL_SPECTRUM_COLORS - 1:
			unlocked_color_index += 1
			lines_cleared_for_current_color = 0
			print("Unlocked color: ", unlocked_color_index)
			
func get_random_piece_color() -> int:
	return randi() % (unlocked_color_index + 1)	

func should_spawn_white_block() -> bool:
	if score_since_last_white >= SCORE_PER_WHITE_BLOCK:
		score_since_last_white -= SCORE_PER_WHITE_BLOCK
		return true
	return false

func get_current_fall_time() -> float:
	var color_reduction = unlocked_color_index * FALL_TIME_DECREASE
	var time_reduction = floor(elapsed_time / TIME_DECREASE_INTERVAL) * TIME_DECREASE_AMOUNT
	var fall_time = BASE_FALL_TIME - color_reduction - time_reduction
	return max(fall_time, MIN_FALL_TIME)
	
func register_line_clear(cleared_color_ids: Array):
	for color_id in cleared_color_ids:
		if color_id == unlocked_color_index:
			lines_cleared_for_current_color += 1
			
	score += 10
	score_since_last_white += 10

	_check_unlock_next_color()
	_update_ui()
	
func _update_ui():
	score_label.text = "Score: " + str(score)
	var color_names = ["Red", "Orange", "Yellow", "Green", "Blue", "Indigo", "Purple"]
	color_label.text = "Color: " + color_names[unlocked_color_index]
	if unlocked_color_index < TOTAL_SPECTRUM_COLORS - 1:
		var threshold = LINES_TO_UNLOCK[unlocked_color_index]
		progress_label.text = "Progress: " + str(lines_cleared_for_current_color) + "/" + str(threshold)
	else:
		progress_label.text = "Max color reached!"
		
func _ready():
	_update_ui()
	
func _process(delta):
	elapsed_time += delta
