extends Node

const TOTAL_SPECTRUM_COLORS = 7
const LINES_TO_UNLOCK = [10, 10, 10, 10, 10, 10, 10]
const BASE_FALL_TIME = 1.0
const FALL_TIME_DECREASE = 0.05
const MIN_FALL_TIME = 0.2
const TIME_DECREASE_INTERVAL = 30.0
const TIME_DECREASE_AMOUNT = 0.02
var elapsed_time = 0.0
const SCORE_PER_WHITE_BLOCK = 50
var score_since_last_white = 0
@onready var score_label = get_node("../UI/ScoreLabel")
@onready var color_label = get_node("../UI/ColorLabel")
@onready var progress_label = get_node("../UI/ProgressLabel")
@onready var clear_row_player = get_node("ClearRowPlayer")
@onready var new_color_player = get_node("NewColorPlayer")
@onready var game_over_player = get_node("GameOverPlayer")
@onready var mutant_player = get_node("MutantPlayer")
@onready var board = get_node("../Board")
@onready var current_piece = get_node("../CurrentPiece")
@onready var game_over_panel = get_node("../UI/GameOverPanel")
@onready var final_score_label = get_node("../UI/GameOverPanel/FinalScoreLabel")

var clear_row_sounds = [
	preload("res://sound_effect/ClearRow1.wav"),
	preload("res://sound_effect/ClearRow2.wav"),
	preload("res://sound_effect/ClearRow3.wav"),
]
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
			new_color_player.play()
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

	_play_clear_row_sound()
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
	mutant_player.play()
	_update_ui()
	
func _process(delta):
	elapsed_time += delta

	if current_piece.is_game_over and not game_over_panel.visible:
		_show_game_over()

func _show_game_over():
	game_over_panel.visible = true
	final_score_label.text = "Final Score: " + str(score)
	game_over_player.play()

func _play_clear_row_sound():
	clear_row_player.stream = clear_row_sounds[randi() % clear_row_sounds.size()]
	clear_row_player.play()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
