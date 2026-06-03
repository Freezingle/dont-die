extends Node2D

@export var pit_scene : PackedScene
@export var bomb_scene : PackedScene
@export var transition_scene: PackedScene
@export var cannon_spawner_scene : PackedScene  # Add this export

enum GamePhase {
	LEVEL_1,
	TRANSITION_TO_LEVEL_2,
	LEVEL_2,
	FINAL_LEVEL,
	VICTORY
}

var game_over := false
var current_phase = GamePhase.LEVEL_1
var elapsed_time := 0
var pit : Node2D
var pit_difficulty_timer := 0.0
var bomb_phase 
var current_cannon_spawner : Node  # Store reference to the current spawner
var saved_spawn_timer_wait_time : float = 2.0  # Save difficulty progression

@onready var game_over_ui = $UI/GameOverUI
@onready var restart_button = $UI/GameOverUI/RestartButton
@onready var announcement_label = $UI/RootUI/AnnouncementLabel
@onready var difficulty_timer = $DifficultyTimer
@onready var level_timer = $LevelTimer
@onready var victory_ui = $UI/VictoryUI
@onready var victory_main_menu_button = $UI/VictoryUI/MainMenu
@onready var victory_label = $UI/VictoryUI/Label

func _process(delta):
	if current_phase != GamePhase.LEVEL_2:
		return
	if pit == null:
		return 
	pit_difficulty_timer += delta
	
	if pit_difficulty_timer >= 5:
		pit_difficulty_timer = 0.0
		pit.increase_difficulty()

func _ready():
	# Get the existing cannon spawner from the scene
	current_cannon_spawner = $World/CannonSpawner
	
	var player = get_tree().get_first_node_in_group("player")
	level_timer.timeout.connect(_on_level_timer_timeout)
	if player:
		player.died.connect(on_player_died)
	difficulty_timer.timeout.connect(increase_difficulty)
	
	restart_button.pressed.connect(restart_game)
	victory_main_menu_button.pressed.connect(_on_main_menu_pressed)

func increase_score():
	if game_over:
		return

func increase_difficulty():
	if current_cannon_spawner and current_cannon_spawner.spawn_timer.wait_time > 0.5:
		current_cannon_spawner.spawn_timer.wait_time -= 0.15
		saved_spawn_timer_wait_time = current_cannon_spawner.spawn_timer.wait_time  # Save the current difficulty

# game clock
func _on_level_timer_timeout():
	elapsed_time += 1

	# LEVEL 2 WARNING
	if current_phase == GamePhase.LEVEL_1:
		var remaining = 60 - elapsed_time

		if remaining <= 5 and remaining > 0:
			show_announcement("Something dangerous is COMING!!")
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
	if current_phase == GamePhase.LEVEL_1 and elapsed_time >= 60:
		start_transition()
	elif current_phase == GamePhase.LEVEL_2 and elapsed_time >= 100:
		start_final_level()

func start_transition():
	current_phase = GamePhase.TRANSITION_TO_LEVEL_2
	
	# Remove the old cannon spawner
	if current_cannon_spawner:
		current_cannon_spawner.queue_free()
		current_cannon_spawner = null
	
	# Remove all existing cannons
	for cannon in get_tree().get_nodes_in_group("cannons"):
		cannon.queue_free()
		
	var transition = transition_scene.instantiate()
	add_child(transition)
	transition.transition_finished.connect(_on_transition_finished)

func _on_transition_finished():
	show_announcement("WARNING\nSTRUCTURAL FAILURE DETECTED")
	await get_tree().create_timer(1.5).timeout
	show_announcement("CENTER HATCH OPENING")
	await get_tree().create_timer(2.5).timeout
	hide_announcement()
	start_level_2()

func start_level_2():
	current_phase = GamePhase.LEVEL_2
	
	# REINSTANTIATE CANNON SPAWNER
	var new_cannon_spawner = cannon_spawner_scene.instantiate()
	$World.add_child(new_cannon_spawner)
	current_cannon_spawner = new_cannon_spawner
	
	# Restore the difficulty progression
	if saved_spawn_timer_wait_time < 2.0:
		current_cannon_spawner.spawn_timer.wait_time = saved_spawn_timer_wait_time
	
	difficulty_timer.stop()
	spawn_pit()
	print("LEVEL 2 STARTED with spawn timer: ", current_cannon_spawner.spawn_timer.wait_time)

func start_final_level():
	current_phase = GamePhase.FINAL_LEVEL
	
	# STOP CANNONS
	if current_cannon_spawner:
		current_cannon_spawner.queue_free()
		current_cannon_spawner = null

	# REMOVE PIT
	if pit:
		pit.queue_free()
		pit = null

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
	victory_label.text = "YOU SURVIVED! GAME OVER!\nThanks for playing!"
	victory_ui.visible = true
	get_tree().paused = true

func restart_game():
	get_tree().paused = false
	
	# Reset variables
	game_over = false
	current_phase = GamePhase.LEVEL_1
	elapsed_time = 0
	pit_difficulty_timer = 0.0
	saved_spawn_timer_wait_time = 2.0
	
	get_tree().reload_current_scene()
	
func show_announcement(text: String):
	announcement_label.visible = true
	announcement_label.text = text

func hide_announcement():
	announcement_label.visible = false

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
