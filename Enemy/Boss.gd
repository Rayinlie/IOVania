extends KinematicBody2D
class_name Boss

onready var spawn_point: Position2D = get_node("Position2D")
const PROJECTILE: PackedScene = preload("res://Mainframe/ImpactWave.tscn")

onready var attack_timer: Timer = get_node("AttackCooldown")
onready var sprite: Sprite = get_node("Sprite")
onready var animation: AnimationPlayer = get_node("AnimationPlayer")
onready var collision: CollisionShape2D = get_node("CollisionShape2D")

onready var attack_range: CollisionShape2D = get_node("AttackDetect/PlayerDetect")

var player_ref: KinematicBody2D = null
var player_ref_damage: KinematicBody2D = null
var player_attack: KinematicBody2D = null
var velocity: Vector2

var suffix: String = "Flip"

var can_attack: bool = false
var can_deal_damage: bool = true

export(int) var move_speed = 50
export(int) var distance_threshold = 15
export(int) var enemy_damage = 10

export(int) var health = 250
export(int) var max_health = 250

export(float) var attackCooldown = 5

export(int) var jump_speed = 190
export(int) var gravity = 600

func _ready():
	if player_ref == null:
		return
	
	if player_ref.is_in_group('player'):
		update_bar()
		return
	
	verify_orientation()
	

func jump(delta) -> void:
	velocity.y += delta * gravity

func _physics_process(delta: float) -> void:
	if player_ref == null:
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
	update_bar()
	
	if health <= 0:
		animation.play("Dead")
		queue_free()
	
	animation.play("Aura")
	
func gain_health(value: int) ->void:
	health += value
	update_bar()

func verify_orientation() -> void:
	if velocity.x > 0:
		sprite.position.x = 0
		sprite.flip_h = false
		attack_range.position.x = -3.5
	
	if velocity.x < 0:
		sprite.position.x = -36
		sprite.flip_h = true
		attack_range.position.x = -62

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
		player_ref_damage.update_health("Damage",enemy_damage)

func _on_AttackDetect_body_entered(body):
	if body.is_in_group("player"):
		player_attack = body
		can_attack = true

func _on_AttackDetect_body_exited(body):
	if body.is_in_group("player"):
		player_attack = null
		can_attack = false

func spawn_projectile() -> void:
	var projectile: ImpactWave = PROJECTILE.instance()
	get_tree().root.call_deferred("add_child",projectile)
	projectile.global_position = spawn_point.global_position

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Aura":
		gain_health(8)
		set_physics_process(true)
		
	if anim_name == "Attack" or anim_name == "AttackFlip":
		set_physics_process(true)
		animation.play("Walk")
		
	if anim_name == "Dead":
		queue_free()

func _on_DetectionArea_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body
		player_ref.updateBossBar(max_health, health)


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("player"):
		player_ref = null


func update_bar():
	if player_ref == null:
		return
	if player_ref.is_in_group('player'):
		player_ref.updateBossBar(max_health, health)
