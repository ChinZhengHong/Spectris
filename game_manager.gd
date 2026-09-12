extends Node

const TOTAL_SPECTRUM_COLORS = 7
const LINES_TO_UNLOCK = 3
const BASE_FALL_TIME = 1.0
const FALL_TIME_DECREASE = 0.1
const MIN_FALL_TIME = 0.2
const SCORE_PER_WHITE_BLOCK = 50
var score_since_last_white = 0
var score = 0
var unlocked_color_index = 0
var lines_cleared_for_current_color = 0


func get_current_target_color() -> int:
	return unlocked_color_index

func _check_unlock_next_color():
	if lines_cleared_for_current_color >= LINES_TO_UNLOCK:
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
	var fall_time = BASE_FALL_TIME - (unlocked_color_index * FALL_TIME_DECREASE)
	return max(fall_time, MIN_FALL_TIME)
	
func register_line_clear(cleared_color_ids: Array):
	for color_id in cleared_color_ids:
		if color_id == unlocked_color_index:
			lines_cleared_for_current_color += 1
			
	score += 10
	score_since_last_white += 10

	_check_unlock_next_color()
