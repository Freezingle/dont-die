extends Node2D

signal transition_finished

@export var projectile_scene : PackedScene

func _ready():
	start_transition()

func start_transition():
	await upper_left_attack()

	await lower_left_attack()

	await diagonal_attack()

	await right_side_sweep()

	await left_side_sweep()

	transition_finished.emit()

func fire_bullet(pos: Vector2, dir: Vector2):
	var bullet = projectile_scene.instantiate()

	bullet.global_position = pos
	bullet.direction = dir.normalized()

	get_parent().add_child(bullet)
	
func upper_left_attack():
	fire_bullet(Vector2(-50, 50), Vector2(1, 0))
	fire_bullet(Vector2(-50, 150), Vector2(1, 0))
	fire_bullet(Vector2(50, -50), Vector2(0, 1))
	fire_bullet(Vector2(150, -50), Vector2(0, 1))

	await get_tree().create_timer(2.0).timeout

func lower_left_attack():
	var h = get_viewport().get_visible_rect().size.y

	fire_bullet(Vector2(-50, h - 50), Vector2(1, 0))
	fire_bullet(Vector2(-50, h - 150), Vector2(1, 0))

	fire_bullet(Vector2(50, h + 50), Vector2(0, -1))
	fire_bullet(Vector2(150, h + 50), Vector2(0, -1))

	await get_tree().create_timer(2.0).timeout
	
func diagonal_attack():
	var w = get_viewport().get_visible_rect().size.x
	var h = get_viewport().get_visible_rect().size.y

	fire_bullet(Vector2(-50,-50), Vector2(1,1))
	fire_bullet(Vector2(w+50,-50), Vector2(-1,1))

	fire_bullet(Vector2(-50,h+50), Vector2(1,-1))
	fire_bullet(Vector2(w+50,h+50), Vector2(-1,-1))

	await get_tree().create_timer(2.0).timeout
	
func right_side_sweep():
	var w = get_viewport().get_visible_rect().size.x

	fire_bullet(Vector2(w+50,100), Vector2.LEFT)
	await get_tree().create_timer(0.15).timeout

	fire_bullet(Vector2(w+50,250), Vector2.LEFT)
	await get_tree().create_timer(0.15).timeout

	fire_bullet(Vector2(w+50,400), Vector2.LEFT)
	await get_tree().create_timer(0.15).timeout

	fire_bullet(Vector2(w+50,550), Vector2.LEFT)

	await get_tree().create_timer(2.0).timeout
	
func left_side_sweep():
	fire_bullet(Vector2(-50,100), Vector2.RIGHT)
	await get_tree().create_timer(0.15).timeout

	fire_bullet(Vector2(-50,250), Vector2.RIGHT)
	await get_tree().create_timer(0.15).timeout

	fire_bullet(Vector2(-50,400), Vector2.RIGHT)
	await get_tree().create_timer(0.15).timeout

	fire_bullet(Vector2(-50,550), Vector2.RIGHT)

	await get_tree().create_timer(2.0).timeout
