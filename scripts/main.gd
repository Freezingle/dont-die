extends Node2D

var score := 0
var game_over := false

@onready var score_label = $UI/ScoreLabel

@onready var game_over_ui = $UI/GameOverUI
@onready var restart_button = $UI/GameOverUI/RestartButton

@onready var score_timer = $ScoreTimer
@onready var difficulty_timer = $DifficultyTimer

@onready var cannon_spawner = $World/CannonSpawner


func _ready():
	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.died.connect(on_player_died)

	restart_button.pressed.connect(restart_game)

	score_timer.timeout.connect(increase_score)
	difficulty_timer.timeout.connect(increase_difficulty)

	update_score_ui()


func increase_score():
	if game_over:
		return

	score += 1
	update_score_ui()


func increase_difficulty():
	if cannon_spawner.spawn_timer.wait_time > 0.5:
		cannon_spawner.spawn_timer.wait_time -= 0.15


func update_score_ui():
	score_label.text = "SCORE: " + str(score)




func on_player_died():
	if game_over:
		return

	game_over = true
	
	game_over_ui.visible = true

	get_tree().paused = true


func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
