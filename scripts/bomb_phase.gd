extends CanvasLayer

signal phase_completed

@export var total_rounds :=5
@export var warning_duration :=5.0
@export var blast_duration :=0.2

var current_round :=0
var player_inside_safe_zone := false
var blinking := false

@onready var danger_overlay = $DangerOverlay
@onready var safe_zone = $SafeZone
@onready var blink_timer = $BlinkTimer
@onready var detonate_timer = $DetonateTimer

func _ready():
	blink_timer.timeout.connect(_on_blink_timer_timeout)
	detonate_timer.timeout.connect(_on_detonate_timer_timeout)
	
	safe_zone.body_entered.connect(_on_safe_zone_entered)
	safe_zone.body_exited.connect(_on_safe_zone_exited)
	start_round()
	
func _on_safe_zone_entered(body):
	if body.is_in_group("player"):
		player_inside_safe_zone = true


func _on_safe_zone_exited(body):
	if body.is_in_group("player"):
		player_inside_safe_zone = false

func start_round():
	current_round += 1

	if current_round > total_rounds:
		phase_completed.emit()
		queue_free()
		return

	spawn_safe_zone()
	blinking = true
	blink_timer.start()
	detonate_timer.start(warning_duration)

func spawn_safe_zone():
	var screen_size = get_viewport().get_visible_rect().size
	var margin := 150
	var x = randf_range(margin, screen_size.x - margin)
	var y = randf_range(margin, screen_size.y - margin)

	safe_zone.global_position = Vector2(x, y)

func _on_blink_timer_timeout():
	if not blinking:
		return
	if danger_overlay.color.a > 0.0:
		danger_overlay.color.a = 0.0
	else:
		danger_overlay.color.a = 0.4

func _on_detonate_timer_timeout():
	blinking = false

	blink_timer.stop()

	danger_overlay.color = Color.WHITE

	check_survival()

	await get_tree().create_timer(blast_duration).timeout

	danger_overlay.color = Color(1, 0, 0, 0)

	await get_tree().create_timer(1.0).timeout

	start_round()

func is_player_fully_inside_safe_zone() -> bool:
	if not player_inside_safe_zone:
		return false

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return false

	var player_collision = player.find_child("CircleShape2D")
	var zone_collision = safe_zone.find_child("CollisionShape2D")

	if player_collision == null or zone_collision == null:
		push_warning("CollisionShape2D missing")
		return false

	var player_shape = player_collision.shape as CircleShape2D
	var zone_shape = zone_collision.shape as CircleShape2D

	if player_shape == null or zone_shape == null:
		push_warning("Shape is not CircleShape2D")
		return false

	var distance = player.global_position.distance_to(safe_zone.global_position)
	return distance + player_shape.radius <= zone_shape.radius

func check_survival():
	if is_player_fully_inside_safe_zone():
		print("SAFE")
		return

	var player = get_tree().get_first_node_in_group("player")

	if player:
		print("DEATH")
		player.die() 
