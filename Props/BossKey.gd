extends StaticBody2D

onready var coiso: KinematicBody2D = null
onready var animate: AnimationPlayer = get_node("AnimationPlayer")
onready var collision: CollisionShape2D = get_node("Collision")

func _physics_process(delta):
	if coiso == null:
		return
		
	if Input.is_action_just_pressed("Interact") and coiso.is_in_group('player'):
		coiso.havekey = true
		queue_free()
	
func _on_Area2D_body_entered(body):
	if body.is_in_group('player'):
		coiso = body
