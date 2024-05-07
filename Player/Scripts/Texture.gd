extends Sprite
class_name PlayerTexture

onready var player: KinematicBody2D = get_parent()
onready var animation: AnimationPlayer = get_node("%Animation")
onready var spawn_point: Position2D = get_node("%SpawnPoint")
onready var collision: CollisionShape2D = get_node("%Collision")
onready var shoot_timer: Timer = get_node("%SuperShoot")

var max_charge = 5
var charge = 0
var on_action: bool = false
var shootcontrol: bool = true

var suffix: String = "Flip"

func _ready() -> void:
	animation.play("Idle")

func animate(velocity: Vector2) -> void:
	verify_orientation(velocity.x)
	
	if on_action:
		return
	
	if velocity.y == 0:
		player.AttackOnAir = false
	
	if velocity.y != 0:
		vertical_behavior(velocity.y)
		return
	
	horizontal_behavior(velocity.x)

func verify_orientation(speed: float) -> void:
	if speed > 0:
		flip_h = false
		spawn_point.position = Vector2(14, 3)
		
	if speed < 0:
		flip_h = true
		spawn_point.position = Vector2(-14, 3)

func action_behavior(action: String) -> void:
	on_action = true
	if action == 'Attack1' or action == 'Attack2' or action == 'Attack3' or action == 'AttackHoldOnAir' or action == 'AttackOnAir2':
		if flip_h == true:
			animation.play(action+suffix)
			return
		else:
			animation.play(action)
			return
	
	animation.play(action)
	

func vertical_behavior(speed: float) -> void:
	if player.DoubleJump == false and player.AttackOnAir == false:
			animation.play("DoubleJump")
			return
	
	if speed > 0:
		animation.play("Fall")
	
	if speed < 0:
		animation.play("Jump")
		

func horizontal_behavior(speed: float) -> void:
	if speed != 0:
		animation.play("Run")
		return
	
	animation.play("Idle")


func on_animation_finished(anim_name: String) -> void:
	if anim_name == "AttackBow":
		if Input.is_action_pressed("Shoot"):
			shoot_timer.start(max_charge)
			action_behavior("HoldingBow")
		else:
			action_behavior("ShootingBow")
	
	if anim_name == "HoldingBow":
		if Input.is_action_just_released("Shoot"):
			shootcontrol = false
		
		if Input.is_action_pressed("Shoot") and shootcontrol:
			if charge < max_charge:
				charge += 1
			action_behavior("HoldingBow")
		else:
			action_behavior("ShootingBow")
			
		print(charge)
			
	if anim_name == "ShootingBow":
		on_action = false
		shootcontrol = true
		player.can_attack = true
		player.set_physics_process(true)
		charge = 0

	if anim_name == "Hitted":
		on_action = false
		player.can_attack = true
		player.set_physics_process(true)

	if anim_name == "Attack1" or anim_name == "Attack1Flip":
		on_action = false
		player.can_attack = true
		player.set_physics_process(true)
		player.combo_initialized = 1

	if anim_name == "Attack2" or anim_name == "Attack2Flip":
		on_action = false
		player.can_attack = true
		player.set_physics_process(true)
		player.combo_initialized = 2
		
	if anim_name == "Attack3" or anim_name == "Attack3Flip":
		on_action = false
		player.can_attack = true
		player.set_physics_process(true)
		player.combo_initialized = 0

	if anim_name == "AttackOnAir1":
		on_action = false
		player.can_attack = true
		player.set_physics_process(true)
		player.combo_initialized = 1

	if anim_name == "AttackOnAir2" or anim_name == "AttackOnAir2Flip":
		on_action = false
		player.can_attack = true
		player.set_physics_process(true)
		player.combo_initialized = 0

	if anim_name == "AttackHoldOnAir" or anim_name == "AttackHoldOnAirFlip":
		on_action = false
		player.can_attack = true
		player.set_physics_process(true)
		player.combo_initialized = 0
		
	if anim_name == "AttackFall":
		on_action = false
		player.can_attack = true
		player.set_physics_process(true)
		player.combo_initialized = 0
		player.AttackOnAir = false
		player.is_attacking = false
		player.DoubleJump = true
		
	if anim_name == "Roll":
		on_action = false
		collision.disabled = false
		player.can_attack = true
		player.set_physics_process(true)
	
	if anim_name == "Dead":
		get_tree().change_scene("res://Scenes/main.tscn")
