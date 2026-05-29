extends CharacterBody2D

@export var move_speed :=500.0

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	#to prevent diagonal movement speedupsd
	input_vector = input_vector.normalized()
	
	velocity = input_vector * move_speed
	move_and_slide()
