extends Node

const TOTAL_SPECTRUM_COLORS = 7
const LINES_TO_UNLOCK = 3

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
	
func register_line_clear(cleared_color_ids: Array):
	for color_id in cleared_color_ids:
		if color_id == unlocked_color_index:
			lines_cleared_for_current_color += 1

	_check_unlock_next_color()
