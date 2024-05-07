extends KinematicBody2D
class_name Enemy2

onready var attack_timer: Timer = get_node("AttackCooldown")
onready var sprite: Sprite = get_node("Texture")
onready var animation: AnimationPlayer = get_node("Animation")
onready var collision: CollisionShape2D = get_node("Collision")

onready var attack_range: CollisionShape2D = get_node("AttackDetect/PlayerDetect")
onready var hp_bar: ProgressBar = get_node("ProgressBar")

var player_ref: KinematicBody2D = null
var player_ref_damage: KinematicBody2D = null
var player_attack: KinematicBody2D = null
var velocity: Vector2

var can_deal_damage: bool = true
var can_attack: bool = false

export(int) var move_speed = 50
export(int) var distance_threshold = 15
export(int) var enemy_damage = 6


export(int) var max_health = 40
export(int) var health = 40

export(float) var attackCooldown = 3.5

func _ready():
	update_bars()
	verify_orientation()
	if player_ref == null:
		action_behavior("Idle")
		return

	if health < 0:
		set_physics_process(false)
		action_behavior("Dead")

func _physics_process(delta: float) -> void:
	if player_ref == null:
		return
		
	move()
	velocity = move_and_slide(velocity)
	verify_orientation()

func move() -> void:
	var x_distance: float = player_ref.global_position.x - global_position.x
	var x_direction: float = sign(x_distance)
	animation.play("Walk")
	if can_attack and can_deal_damage:
		attack_timer.start(attackCooldown)
		can_deal_damage = false
		if sprite.flip_h == false:
			action_behavior("Attack1A")
			
		if sprite.flip_h == true:
			action_behavior("Attack1AFlip")
		
	else:
		set_physics_process(true)
		velocity.x = 0
		
	
	if abs(x_distance) > distance_threshold:
		velocity.x = x_direction * move_speed

func _on_AttackCooldown_timeout():
	can_deal_damage = true

func update_health(value: int) -> void:
	health = clamp(health - value, 0, 25)
	update_bars()
	if health <= 0:
		collision.disabled = true
		remove_from_group('Enemy')
		set_physics_process(false)
		action_behavior("Dead")
		

	set_physics_process(false)
	animation.play("Hit")

func verify_orientation() -> void:
	if velocity.x > 0:
		attack_range.position.x = 3
		sprite.position.x = 0
		sprite.flip_h = false
	
	if velocity.x < 0:
		attack_range.position.x = -40
		sprite.position.x = -36
		sprite.flip_h = true

func action_behavior(action: String) -> void:
	if action == 'Attack1A' or action == 'Attack1AFlip':
		set_physics_process(false)
		animation.play(action)
		return
	
	if action == 'Attack1B':
		set_physics_process(false)
		animation.play(action)
		return
	
	if action == 'Attack2A':
		set_physics_process(false)
		animation.play(action)
		return
	
	if action == 'Dead':
		can_deal_damage = false
		set_physics_process(false)
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
		
	if anim_name == "Attack1A" or anim_name == "Attack1AFlip":
		set_physics_process(true)
		
	if anim_name == "Dead":
		queue_free()


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("player"):
		player_ref = null


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body


func _on_AttackArea_body_exited(body):
	if body.is_in_group("player"):
		player_ref_damage = null


func _on_AttackDetect_body_entered(body):
	if body.is_in_group("player"):
		player_attack = body
		can_attack = true

func _on_AttackDetect_body_exited(body):
	if body.is_in_group("player"):
		player_attack = null
		can_attack = false

func update_bars()-> void:
	hp_bar.max_value = max_health
	hp_bar.value = health
	return
