extends Node2D

@export var pit_scene : PackedScene

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


@onready var game_over_ui = $UI/GameOverUI
@onready var restart_button = $UI/GameOverUI/RestartButton
@onready var difficulty_timer = $DifficultyTimer
@onready var level_label = $UI/RootUI/LevelLabel
@onready var timer_label = $UI/RootUI/TimerLabel
@onready var cannon_spawner = $World/CannonSpawner
@onready var level_timer = $LevelTimer


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

	restart_button.pressed.connect(restart_game)
	difficulty_timer.timeout.connect(increase_difficulty)
	level_label.text = "LEVEL 1"
	update_timer_ui()


func increase_score():
	if game_over:
		return


func increase_difficulty():
	if cannon_spawner.spawn_timer.wait_time > 0.5:
		cannon_spawner.spawn_timer.wait_time -= 0.15


# game clock
func _on_level_timer_timeout():
	elapsed_time +=1
	update_timer_ui()
	check_phase_progression()

func update_timer_ui():
	match current_phase:
		GamePhase.LEVEL_1:
			timer_label.text = "NEXT LEVEL: " + str(max(0,60-elapsed_time))
		GamePhase.LEVEL_2:
			timer_label.text = "FINAL LEVEL: " + str(max(0,90-elapsed_time))

func check_phase_progression():
	if current_phase == GamePhase.LEVEL_1 and elapsed_time >= 60:
		start_level_2()
	elif current_phase == GamePhase.LEVEL_2 and elapsed_time >=100:
		start_final_level()
		
		
func start_level_2():
	current_phase = GamePhase.LEVEL_2
	level_label.text = "LEVEL 2"
	difficulty_timer.stop()
	spawn_pit()
	print("LEVEL 2 STARTED")

func start_final_level():
	current_phase = GamePhase.FINAL_LEVEL
	level_label.text = "FINAL LEVEL"
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

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
