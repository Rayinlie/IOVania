extends KinematicBody2D
class_name Enemy3

onready var attack_timer: Timer = get_node("AttackCooldown")
onready var sprite: Sprite = get_node("Sprite")
onready var animation: AnimationPlayer = get_node("AnimationPlayer")
onready var collision: CollisionShape2D = get_node("CollisionShape2D")

onready var attack_range: CollisionShape2D = get_node("AttackDetect/PlayerDetect")
onready var hp_bar: ProgressBar = get_node("ProgressBar")

var player_ref: KinematicBody2D = null
var player_ref_damage: KinematicBody2D = null
var player_attack: KinematicBody2D = null
var velocity: Vector2

var suffix: String = "Flip"

var can_attack: bool = false
var can_deal_damage: bool = true

export(int) var move_speed = 50
export(int) var distance_threshold = 15
export(int) var enemy_damage = 5

export(int) var max_health = 15
export(int) var health = 15

export(float) var attackCooldown = 3

export(int) var jump_speed = 190
export(int) var gravity = 600

func _ready():
	update_bars()
	verify_orientation()
	if player_ref == null:
		action_behavior("Idle")
		return

	if health < 0:
		set_physics_process(false)
		action_behavior("Dead")

func jump(delta) -> void:
	velocity.y += delta * gravity

func _physics_process(delta: float) -> void:
	if player_ref == null:
		action_behavior("Idle")
		return
		
	move()
	jump(delta)
	velocity = move_and_slide(velocity)
	verify_orientation()

func move() -> void:
	var x_distance: float = player_ref.global_position.x - global_position.x
	var x_direction: float = sign(x_distance)
	animation.play("Walk")
	if can_attack and can_deal_damage:
		attack_timer.start(attackCooldown)
		can_deal_damage = false
		action_behavior("Attack")
		velocity.x = 0
	
	if abs(x_distance) > distance_threshold:
		velocity.x = x_direction * move_speed

func _on_AttackCooldown_timeout():
	can_deal_damage = true

func update_health(value: int) -> void:
	set_physics_process(false)
	health -= value
	update_bars()
	if health <= 0:
		collision.disabled = true
		remove_from_group('Enemy')
		set_physics_process(false)
		action_behavior("Dead")
		
	
	animation.play("Hit")

func verify_orientation() -> void:
	if velocity.x > 0:
		sprite.position.x = 0
		sprite.flip_h = false
		attack_range.position.x = 10
	
	if velocity.x < 0:
		sprite.position.x = -23
		sprite.flip_h = true
		attack_range.position.x = -31

func action_behavior(action: String) -> void:
	if action == 'Attack':
		set_physics_process(false)
		if sprite.flip_h == true:
			animation.play(action+suffix)
			return
		
		if sprite.flip_h == false:
			animation.play(action)
			return
	animation.play(action)

func _on_AttackArea_body_entered(body):
	if body.is_in_group("player"):
		player_ref_damage = body
		player_ref.update_health("Damage",enemy_damage)


func _on_Animation_animation_finished(anim_name: String) -> void:
	if anim_name == "Hit":
		if health > 0:
			set_physics_process(true)
			action_behavior("Idle")
		else:
			action_behavior("Dead")
		
	if anim_name == "Attack" or anim_name == "AttackFlip":
		set_physics_process(true)
		
	if anim_name == "Dead":
		queue_free()


func _on_AttackDetect_body_entered(body):
	if body.is_in_group("player"):
		player_attack = body
		can_attack = true



func _on_AttackDetect_body_exited(body):
	if body.is_in_group("player"):
		player_attack = null
		can_attack = false


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("player"):
		player_ref = null


func _on_AttackArea_body_exited(body):
	if body.is_in_group("player"):
		player_ref_damage = null
		
func update_bars()-> void:
	hp_bar.max_value = max_health
	hp_bar.value = health
	return
