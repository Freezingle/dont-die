extends Node2D

@export var rotation_speed: = 6.0
@export var projectile_scene : PackedScene

var player: CharacterBody2D
@onready var laser = $Laser
@onready var shoot_timer = $ShootTimer
@onready var lifetime_timer = $LifetimeTimer

func _ready():
	player = get_tree().get_first_node_in_group("player")
	laser.visible = true
	shoot_timer.timeout.connect(shoot)
	lifetime_timer.timeout.connect(queue_free)
	
	shoot_timer.start()
	lifetime_timer.start()

func _process(delta):
	if player ==null:
		return
	var direction = global_position.direction_to(player.global_position)
	var target_rotation = direction.angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)


func shoot ():
	laser.visible =false
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	#forward direction based on canon rotation
	projectile.direction = Vector2.RIGHT.rotated(rotation)
	get_parent().add_child(projectile)
