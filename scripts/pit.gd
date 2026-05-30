extends Node2D

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
	shoot_timer.timeout.connect(start_attack)
	telegraph_timer.timeout.connect(shoot_attack)

func start_attack():
	
	top_angle = deg_to_rad(randf_range(-60,60))
	bottom_angle = deg_to_rad(randf_range(120,240))
	left_angle = deg_to_rad (randf_range(150,210))
	right_angle = deg_to_rad (randf_range(-30,30))
	
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

func shoot_attack():
	print("PIT VOLLEY")
	laser_top.visible = false
	laser_bottom.visible = false
	laser_left.visible = false
	laser_right.visible = false
	
	





 
