extends StaticBody2D

onready var player: KinematicBody2D = null
onready var animate: AnimationPlayer = get_node("AnimationPlayer")
onready var collision: CollisionShape2D = get_node("Collision")

var canget_hp_potion: bool = true
var canget_mp_potion: bool = true
var canget_hp_mult_potion: bool = true
var canget_skill1: bool = true
var canget_skill2: bool = true
var canget_skill3: bool = true
var canget_skill4: bool = true

func _physics_process(delta):
	if player == null:
		return
	
	if Input.is_action_just_pressed("Interact") and player.is_in_group('player'):
		animate.play("Open")
		
	
func _on_Area2D_body_entered(body):
	if body.is_in_group('player'):
		player = body

func give_player_item():
	if player.health_potion == 0:
		player.health_potion += 1
		player.shownot1()
		return
	
	if player.mana_potion == 0:
		player.mana_potion += 1
		player.shownot2()
		return
	
	if player.Health_multiplier == 1 and canget_hp_mult_potion:
		player.Health_multiplier += 1
		canget_hp_mult_potion = false
		player.shownot3()
		return

	if player.haveskill2 == false:
		player.haveskill2 = true
		player.shownot4()
		return
	
	if player.haveskill3 == false:
		player.haveskill3 = true
		player.shownot5()
		return
	
	if player.haveskill4 == false:
		player.haveskill4 = true
		player.shownot6()
		return
	
	if player.health_potion >= 1:
		player.health_potion += 1
		player.shownot1()
		return
	
	if player.mana_potion >= 1:
		player.mana_potion += 1
		player.shownot2()
		return


func _on_AnimationPlayer_animation_finished(anim_name):
	give_player_item()
	player.update_bars()
	set_physics_process(false)
	collision.disabled = true


func _on_Area2D_body_exited(body):
	if body.is_in_group('player'):
		player = null
