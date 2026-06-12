extends CharacterBody2D
#TODO: MAKE MOVEMENT MORE SNAPPY AND QUICK
#TODO: MAKE USER STOP MOVING WHEN IT TOUCHES BORDER

signal died

@export var max_speed :=700.0
@export var acceleration := 6000.0
@export var friction := 2000.0
@export var rotation_speed := 20.0

#for mobile devices
var touch_target := Vector2.ZERO
var using_touch := false
var is_dead := false

func _ready():
	touch_target = global_position

func _physics_process(delta):
	handle_keyboard_input(delta)
	target_to_mouse(delta)
	clamp_to_screen()
	move_and_slide()

func target_to_mouse(delta):
	var mouse_pos = get_global_mouse_position()
	var to_mouse = mouse_pos - global_position
	
	if to_mouse.length()<30.0:
		return
	var target_angle = to_mouse.angle()
	rotation = lerp_angle(rotation,target_angle,rotation_speed*delta)
	

func handle_keyboard_input(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	#to prevent diagonal movement speedupsd
	input_vector = input_vector.normalized()
	
	if input_vector!= Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction* delta)

func clamp_to_screen():
	var screen_size = get_viewport_rect().size
	
	global_position.x = clamp (global_position.x, 0, screen_size.x)
	global_position.y = clamp(global_position.y, 0, screen_size.y)
		
func die():
	if is_dead:
		return
	is_dead = true
	died.emit()
	print("Player died")
	queue_free()
