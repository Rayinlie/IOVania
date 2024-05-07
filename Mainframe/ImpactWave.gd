extends Area2D
class_name ImpactWave

onready var sprite: Sprite = get_node("Texture")
onready var animation: AnimationPlayer = get_node("AnimationPlayer")

export(int) var damage = 20

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.update_health(damage)

func _on_animation_finished(_anim_name: String) -> void:
	queue_free()
