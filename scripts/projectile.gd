extends Area2D


@export var speed :=1200.0
var direction := Vector2.RIGHT

func _ready():
	#Area2D emits the body_entered signal whenever a physics body enters its collision area.
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
func _physics_process(delta):
	global_position+= direction * speed *delta
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		#body.die()
		#this free is deleting projectile
		queue_free() 
