extends Area2D
class_name Arrow

onready var sprite: Sprite = get_node("Texture")
onready var animation: AnimationPlayer = get_node("AnimationPlayer")
onready var poder: Sprite = get_node("Poder")
var charger = 0

var direction: float = 1.0

export(int) var speed = 180
export(int) var damage = 4


func _ready() -> void:
	if direction == -1.0:
		sprite.flip_h = true
		poder.flip_h = true
		poder.position.x = 17
	
	if charger == 0:
		animation.play("Idle")
		
	if charger > 0:
		animation.play("Charged")
	
	
		
func _physics_process(delta: float) -> void:
	translate(Vector2(delta * direction * speed, 0))

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.update_health(damage)
		queue_free()
	
	if body is TileMap:
		animation.play("Stuck")
		set_physics_process(false)
		
	

func _on_animation_finished(_anim_name: String) -> void:
	queue_free()

func charged_damage():
	if charger != null:
		damage = damage*(charger/2)


func _on_screen_exited():
	queue_free()

