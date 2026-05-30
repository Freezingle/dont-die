extends Area2D

@export var projectile_scene: PackedScene
@export var projectile_speed := 700.0
@export var attack_interval := 2.5

#ingame variables (floats)
var top_angle := 0.0
var bottom_angle := 0.0
var left_angle :=0.0
var right_angle := 0.0

@onready var laser_top = $LaserTop
@onready var laser_bottom = $LaserBottom
@onready var laser_right = $LaserRight
@onready var laser_left = $LaserLeft
@onready var shoot_timer = $ShootTimer
@onready var telegraph_timer = $TelegraphTimer

func _ready():
	body_entered.connect(_on_body_entered)
	shoot_timer.wait_time = attack_interval
	shoot_timer.timeout.connect(start_attack)
	telegraph_timer.timeout.connect(shoot_attack)

func start_attack():
	
	top_angle    = deg_to_rad(randf_range(250, 290))
	right_angle  = deg_to_rad(randf_range(-20, 20))
	bottom_angle = deg_to_rad(randf_range(70, 110))
	left_angle   = deg_to_rad(randf_range(160, 200))
	
	draw_laser(laser_top,top_angle)
	draw_laser(laser_bottom, bottom_angle)
	draw_laser(laser_left, left_angle)
	draw_laser(laser_right, right_angle)
	telegraph_timer.start()
	
func draw_laser(line:Line2D, angle:float):
	var length = 1200.0
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.RIGHT.rotated(angle) * length)
	line.visible = true

func fire_projectile (angle:float):
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = Vector2.RIGHT.rotated(angle)
	projectile.speed = projectile_speed
	get_parent().add_child(projectile)

func shoot_attack():
	
	fire_projectile(top_angle)
	fire_projectile(bottom_angle)
	fire_projectile(right_angle)
	fire_projectile(left_angle)
	
	laser_top.visible = false
	laser_bottom.visible = false
	laser_left.visible = false
	laser_right.visible = false

func increase_difficulty():
	projectile_speed += 100
	
	if shoot_timer.wait_time >0.4:
		shoot_timer.wait_time-= 0.2
		
func _on_body_entered(body):
	if body.is_in_group("player"):
		body.die()





 
