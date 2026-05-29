extends Node2D

@export var rotation_speed: = 6.0
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
	print ("BANG!")
