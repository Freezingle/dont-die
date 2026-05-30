extends Node 

@export var cannon_scene : PackedScene
@onready var spawn_timer :Timer = $SpawnTimer

func _ready():
	spawn_timer.timeout.connect(spawn_cannon)
	
func spawn_cannon():
	var cannon = cannon_scene.instantiate()
	var screen_size = get_viewport().get_visible_rect().size
	var spawn_position = get_random_edge_position(screen_size)
	cannon.global_position = spawn_position
	get_parent().add_child(cannon)

func get_random_edge_position(screen_size: Vector2) -> Vector2:
	var edge = randi() % 4

	match edge:
		0:
			# TOP
			return Vector2(randf_range(0, screen_size.x), -50)

		1:
			# BOTTOM
			return Vector2(randf_range(0, screen_size.x), screen_size.y + 50)

		2:
			# LEFT
			return Vector2(-50, randf_range(0, screen_size.y))

		_:
			# RIGHT
			return Vector2(screen_size.x + 50, randf_range(0, screen_size.y))
