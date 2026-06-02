extends Node2D

@export var pit_scene : PackedScene
@export var bomb_scene : PackedScene

enum GamePhase {
	LEVEL_1,
	LEVEL_2,
	FINAL_LEVEL,
	VICTORY
}

var game_over := false
var current_phase = GamePhase.LEVEL_1
var elapsed_time :=0
var pit : Node2D #storing pit reference for increasing difficulty later
var pit_difficulty_timer :=0.0
var bomb_phase 


@onready var game_over_ui = $UI/GameOverUI
@onready var restart_button = $UI/GameOverUI/RestartButton
@onready var announcement_label = $UI/RootUI/AnnouncementLabel
@onready var difficulty_timer = $DifficultyTimer
@onready var timer_label = $UI/RootUI/TimerLabel
@onready var cannon_spawner = $World/CannonSpawner
@onready var level_timer = $LevelTimer
@onready var cannon_spawnner = $World/CannonSpawner
@onready var victory_ui = $UI/VictoryUI
@onready var victory_main_menu_button = $UI/VictoryUI/MainMenu
@onready var victory_label = $UI/VictoryUI/Label

func _process (delta):
	if current_phase != GamePhase.LEVEL_2:
		return
	if pit ==null:
		return 
	pit_difficulty_timer +=delta
	
	if pit_difficulty_timer >=5:
		pit_difficulty_timer = 0.0
		pit.increase_difficulty()

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	level_timer.timeout.connect(_on_level_timer_timeout)
	if player:
		player.died.connect(on_player_died)
	difficulty_timer.timeout.connect(increase_difficulty)
	
	restart_button.pressed.connect(restart_game)

func increase_score():
	if game_over:
		return


func increase_difficulty():
	if cannon_spawner.spawn_timer.wait_time > 0.5:
		cannon_spawner.spawn_timer.wait_time -= 0.15


# game clock
func _on_level_timer_timeout():
	elapsed_time += 1

	# LEVEL 2 WARNING
	if current_phase == GamePhase.LEVEL_1:
		var remaining = 60 - elapsed_time

		if remaining <= 5 and remaining > 0:
			show_announcement("WARNING\nCENTER HATCH OPENING\n" + str(remaining))

		if remaining == 0:
			hide_announcement()

	# FINAL LEVEL WARNING
	if current_phase == GamePhase.LEVEL_2:
		var remaining = 100 - elapsed_time

		if remaining <= 5 and remaining > 0:
			show_announcement("WARNING\nEXPLOSIONS IN\n" + str(remaining))

		if remaining == 0:
			hide_announcement()

	check_phase_progression()


func check_phase_progression():
	if current_phase == GamePhase.LEVEL_1 and elapsed_time >=60:
		start_level_2()
	elif current_phase == GamePhase.LEVEL_2 and elapsed_time >=100:
		start_final_level()
		
		
func start_level_2():
	current_phase = GamePhase.LEVEL_2
	difficulty_timer.stop()
	spawn_pit()
	print("LEVEL 2 STARTED")

func start_final_level():
	current_phase = GamePhase.FINAL_LEVEL
	# STOP CANNONS
	if cannon_spawner:
		cannon_spawner.queue_free()

	# REMOVE PIT
	if pit:
		pit.queue_free()

	spawn_bomb_phase()

	print("FINAL LEVEL STARTED")

func on_player_died():
	if game_over:
		return

	game_over = true
	
	game_over_ui.visible = true

	get_tree().paused = true

func spawn_pit():
	if pit:
		return 
	pit = pit_scene.instantiate()
	var screen_size = get_viewport().get_visible_rect().size
	pit.global_position = screen_size / 2
	$World.add_child(pit)

func spawn_bomb_phase():
	if bomb_phase:
		return
	bomb_phase = bomb_scene.instantiate()
	add_child(bomb_phase)
	bomb_phase.phase_completed.connect(_on_bomb_phase_completed)
	
func _on_bomb_phase_completed():
	game_over = true

	victory_label.text = "YOU SURVIVED!GAME OVER!\n Thanks for playing!"
	victory_ui.visible = true
	get_tree().paused = true

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func show_announcement(text:String):
	announcement_label.visible = true
	announcement_label.text = text

func hide_announcement():
	announcement_label.visible = false


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
