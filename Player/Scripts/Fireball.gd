extends Area2D
class_name Fireball

onready var sprite: Sprite = get_node("Texture")
onready var animation: AnimationPlayer = get_node("AnimationPlayer")

var direction: float = 1.0

export(int) var speed = 180
export(int) var damage = 8


func _ready() -> void:
	if direction == -1.0:
		sprite.flip_h = false
		
func _physics_process(delta: float) -> void:
	translate(Vector2(delta * direction * speed, 0))


func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.update_health(damage)
		queue_free()


func _on_Notifier2D_screen_exited():
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
