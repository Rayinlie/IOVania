extends KinematicBody2D
class_name Player

const PROJECTILE: PackedScene = preload("res://Player/Scene/Arrow.tscn")
const SKILL1: PackedScene = preload("res://Player/Scene/Fireball.tscn")
const SKILL4: PackedScene = preload("res://Player/Scene/Waterball.tscn")

onready var combo_timer: Timer = get_node("ComboTimer")
onready var dash_cooldown: Timer = get_node("DashCooldown")
onready var sprite: Sprite = get_node("Texture")
onready var spawn_point: Position2D = get_node("SpawnPoint")
onready var collision: CollisionShape2D = get_node("Collision")
onready var hp_bar: ProgressBar = get_node("Camera2D/HPBar")
onready var boss_bar: ProgressBar = get_node("Camera2D/BossBar")
onready var mana_bar: ProgressBar = get_node("Camera2D/ManaBar")

onready var receiveTimer: Timer = get_node("Node2D/TimerNotifier")

onready var shoot_timer: Timer = get_node("SuperShoot")

onready var effect: Timer = get_node("MoveSpeedAdd")

var havekey: bool = false


onready var receivehppotion: Node2D = get_node("Node2D/NotifierItem")
onready var receivemppotion: Node2D = get_node("Node2D/NotifierItem2")
onready var receivehpmult: Node2D = get_node("Node2D/NotifierItem3")
onready var receiveskill2: Node2D = get_node("Node2D/NotifierItem4")
onready var receiveskill3: Node2D = get_node("Node2D/NotifierItem5")
onready var receiveskill4: Node2D = get_node("Node2D/NotifierItem6")

onready var skill1: TileMap = get_node("Skill1")
onready var skill1_cooldown: Timer = get_node("TimerSkill1")
onready var skill2: TileMap = get_node("Skill2")
onready var skill2_cooldown: Timer = get_node("TimerSkill2")
onready var skill3: TileMap = get_node("Skill3")
onready var skill3_cooldown: Timer = get_node("TimerSkill3")
onready var skill4: TileMap = get_node("Skill4")
onready var skill4_cooldown: Timer = get_node("TimerSkill4")

onready var hptext: Label = get_node("HPpotions")
onready var mptext: Label = get_node("MPpotions")

var spawnpoint: Position2D = null

var velocity: Vector2
var can_attack: bool = true
var combo_initialized = 0
var is_attacking: bool
var DoubleJump: bool = true
var AttackOnAir: bool = false

var haveskill1: bool = true
var haveskill2: bool = false
var haveskill3: bool = false
var haveskill4: bool = false

var can_use_skill1: bool = true
var can_use_skill2: bool = true
var can_use_skill3: bool = true
var can_use_skill4: bool = true

var CanDash = true
var shootcontrol = true

var enemy_ref: KinematicBody2D = null

export(int) var max_health = 100
export(int) var health = 100
export(int) var max_mana = 40
export(int) var mana = 40
export(int) var move_speed = 120
export(int) var jump_speed = 180
export(int) var sword_damage = 8

var guarda_move_speed: int = move_speed

export(int) var mana_potion = 1
export(int) var health_potion = 1
export(float) var Health_multiplier = 1

export(float) var combo_time = 2.0
export(Array) var attack_range
export(int) var gravity


func _ready():
	skill1.visible = false
	skill2.visible = false
	skill3.visible = false
	skill4.visible = false

	update_bars()


func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("HealthPotion") or Input.is_action_just_pressed("ManaPotion"):
		Use_Potion()
	
	if haveskill1 == true:
		skill1.visible = true
	
	if haveskill2 == true:
		skill2.visible = true
		
	if haveskill3 == true:
		skill3.visible = true
		
	if haveskill4 == true:
		skill4.visible = true
	
	cast_skill1()
	cast_skill2()
	cast_skill3()
	cast_skill4()
	move()
	shoot()
	attack(delta)
	jump(delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	sprite.animate(velocity)
	
	if is_attacking and is_on_floor() and AttackOnAir and not DoubleJump:
		sprite.action_behavior("AttackFall")
		
	
	
func move() -> void:
	if AttackOnAir:
		return
	
	velocity.x = move_speed * get_direction()

func get_direction() -> float:
	if CanDash == true and Input.is_action_just_pressed("Roll"):
		collision.disabled = true
		CanDash = false
		dash_cooldown.start()
		sprite.action_behavior("Roll")
		return (Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")) * 30
	else:
		return Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")
	
func shoot() -> void:
	if Input.is_action_just_pressed("Shoot") and shootcontrol and can_attack and is_on_floor():
		sprite.action_behavior("AttackBow")
		can_attack = false

func jump(delta) -> void:
	velocity.y += delta * gravity
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		DoubleJump = true
		velocity.y = - jump_speed
		
	
	if Input.is_action_just_pressed("Jump") and not is_on_floor() and DoubleJump:
		DoubleJump = false
		velocity.y = -jump_speed
		
func spawn_projectile() -> void:
	var projectile: Arrow = PROJECTILE.instance()
	if sprite.charge >= 1:
		projectile.charger = sprite.charge
		mana -= sprite.charge
		update_bars()
		projectile.charged_damage()
	print(projectile.damage)
	get_tree().root.call_deferred("add_child",projectile)
	projectile.direction = sign(spawn_point.position.x)
	projectile.global_position = spawn_point.global_position

	

func attack(delta) -> void:	
	if can_attack == false:
		return
	
	if Input.is_action_just_pressed("Attack") and can_attack and is_on_floor() and combo_initialized == 0:
		chante_attack_state(true)
		combo_timer.start(combo_time)
		sprite.action_behavior("Attack1")
		
	if Input.is_action_just_pressed("Attack") and combo_initialized == 1 and is_on_floor() and can_attack:
		chante_attack_state(true)
		sprite.action_behavior("Attack2")
		combo_timer.stop()
		combo_timer.start()
	
	if Input.is_action_just_pressed("Attack") and combo_initialized == 2 and is_on_floor() and can_attack:
		chante_attack_state(true)
		sprite.action_behavior("Attack3")
		combo_timer.stop()
		combo_timer.start()
	
	if Input.is_action_just_pressed("Attack") and can_attack and not is_on_floor() and combo_initialized == 0 and DoubleJump:
		chante_attack_state(true)
		combo_timer.start(combo_time)
		AttackOnAir = true
		DoubleJump = false
		sprite.action_behavior("AttackOnAir1")
		
	if Input.is_action_just_pressed("Attack") and can_attack and not is_on_floor() and combo_initialized == 1 and not DoubleJump and AttackOnAir:
		chante_attack_state(true)
		combo_timer.start(combo_time)
		AttackOnAir = true
		DoubleJump = false
		sprite.action_behavior("AttackOnAir2")
		
	if Input.is_action_just_pressed("Attack") and can_attack and not is_on_floor() and combo_initialized == 0 and not DoubleJump and not AttackOnAir:
		is_attacking = true
		combo_timer.start(combo_time)
		AttackOnAir = true
		DoubleJump = false
		sprite.action_behavior("AttackHoldOnAir")
		velocity.y += jump_speed
		
		
func _on_ComboTimer_timeout():
	combo_initialized = 0

func chante_attack_state(state: bool)-> void:
	is_attacking = state
	set_physics_process(not state)

func apply_knockback(target_position: Vector2) -> void:
	sprite.action_behavior("Hitted")
	
	
func kill() -> void:
	sprite.action_behavior("Dead")

func update_health(type: String, value: int, target_position = Vector2.ZERO) -> void:
	match type:
		'Heal':
			health = clamp(health + value, 0, max_health)
			
		'Damage':
			health = clamp(health - value, 0, max_health)
			
			if health == 0:
				set_physics_process(false)
				update_bars()
				kill()
				return
			
			apply_knockback(target_position)
	update_bars()

func get_attack() -> int:
	return randi() % attack_range.max() + attack_range.min()

func _on_AttackArea_body_exited(body):
	if body.is_in_group("Enemy"):
		enemy_ref = null

func _on_AttackArea_body_entered(body):
	if body.is_in_group("Enemy"):
		enemy_ref = body
		enemy_ref.update_health(sword_damage)

func _on_DashCooldown_timeout():
	CanDash = true


func update_bars()-> void:
	hp_bar.max_value = max_health
	hp_bar.value = health
	mana_bar.max_value = max_mana
	mana_bar.value = mana
	hptext.text = String(health_potion)
	mptext.text = String(mana_potion)
	return

func updateBossBar(max_value: int, value: int):
	boss_bar.visible = true
	boss_bar.max_value = max_value
	boss_bar.value = value

func Use_Potion():
	if Input.is_action_just_pressed("HealthPotion"):
		if health < max_health and health_potion > 0:
			update_health("Heal", 10 * Health_multiplier)
			health_potion -= 1
			update_bars()

		
	if Input.is_action_just_pressed("ManaPotion"):
		if mana < max_mana and mana_potion > 0:
			mana += 15
			mana_potion -= 1
			update_bars()
	

func cast_skill1():
	if haveskill1 == true and Input.is_action_just_pressed("Skill1") and mana >= 5:
		spawn_magic(1)

func cast_skill2():
	if haveskill2 == true and Input.is_action_just_pressed("Skill2"):
		spawn_magic(2)

func cast_skill3():
	if haveskill3 == true and Input.is_action_just_pressed("Skill3"):
		spawn_magic(3)

func cast_skill4():
	if haveskill4 == true and Input.is_action_just_pressed("Skill4") and mana >= 5:
		spawn_magic(4)

func spawn_magic(value: int) -> void:
	if value == 1 and can_use_skill1 == true:
		var magic: Fireball = SKILL1.instance()
		mana -= 5
		update_bars()
		get_tree().root.call_deferred("add_child",magic)
		magic.direction = sign(spawn_point.position.x)
		magic.global_position = spawn_point.global_position
		skill1_cooldown.start(7)
		can_use_skill1 = false
		return
	
	if value == 2 and can_use_skill2 == true:
		mana -= 10
		update_bars()
		move_speed += 80
		skill2_cooldown.start(15)
		effect.start(10)
		can_use_skill2 = false
		return
		
	if value == 3 and can_use_skill3 == true:
		mana -= 10
		update_health("Heal", 50)
		update_bars()
		skill3_cooldown.start(15)
		can_use_skill3 = false
		return
	
	if value == 4 and can_use_skill4 == true:
		var magic: Waterball = SKILL4.instance()
		mana -= 3
		update_bars()
		get_tree().root.call_deferred("add_child",magic)
		magic.direction = sign(spawn_point.position.x)
		magic.global_position = spawn_point.global_position
		skill4_cooldown.start(7)
		can_use_skill4 = false
		return

func _on_TimerSkill1_timeout():
	can_use_skill1 = true


func _on_TimerSkill2_timeout():
	can_use_skill2 = true


func _on_TimerSkill3_timeout():
	can_use_skill3 = true


func _on_TimerSkill4_timeout():
	can_use_skill4 = true


func _on_MoveSpeedAdd_timeout():
	move_speed = guarda_move_speed

func item_recebido():
	receiveTimer.start(3)

func shownot1():
	receivehppotion.visible = true
	item_recebido()

func shownot2():
	receivemppotion.visible = true
	item_recebido()

func shownot3():
	receivehpmult.visible = true
	item_recebido()

func shownot4():
	receiveskill2.visible = true
	item_recebido()
	
func shownot5():
	receiveskill3.visible = true
	item_recebido()
	
func shownot6():
	receiveskill4.visible = true
	item_recebido()

func freeze(state: bool) -> void:
	set_physics_process(state)


func _on_TimerNotifier_timeout():
	receivehppotion.visible = false
	receivemppotion.visible = false
	receivehpmult.visible = false
	receiveskill2.visible = false
	receiveskill3.visible = false
	receiveskill4.visible = false
