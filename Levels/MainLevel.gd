extends Node2D
class_name level1

onready var sound: AudioStreamPlayer = get_node("AudioStreamPlayer")
onready var enemys: Node2D = get_node("Enemy")
onready var player: KinematicBody2D = get_node("Player")
onready var checkpoint: StaticBody2D = null
onready var menu: Node2D = get_node("Player/Menu")
onready var bossdoor2: TileMap = get_node("Map/Porta")
onready var bossdoor: CollisionShape2D = get_node("Map/Porta/Area2D/CollisionShape2D")

var is_stopped: bool = false

func _ready() -> void:
	menu.visible = false
	sound.playing = true

func _physics_process(delta: float) -> void:
	verifica_menu()
	
	if player.havekey == true:
		bossdoor2.visible = false
		bossdoor.disabled = true

func verifica_menu():
	if Input.is_action_just_pressed("Menu"):
		
		if is_stopped == false:
			print("Pausado")
			is_stopped = true
			Stop_time()
			menu.visible = true
			return

func _on_AudioStreamPlayer_finished():
	pass # Replace with function body.

func Stop_time():
	var count = enemys.get_child_count()
	print(count)
	var i: int = 0
	while i < count:
		var ref = enemys.get_child(i)
		ref.set_physics_process(false)
		i += 1
	player.set_physics_process(false)
	return


func _on_Area2D_body_entered(body):
	player.position.x


func _on_Continuar_pressed():
	menu.visible = false
	var count = enemys.get_child_count()
	var i: int = 0
	while i < count:
		var ref = enemys.get_child(i)
		ref.set_physics_process(true)
		i += 1
	player.set_physics_process(true)
	is_stopped = false
	return


func _on_Sair_pressed():
	get_tree().change_scene("res://Scenes/main.tscn")
