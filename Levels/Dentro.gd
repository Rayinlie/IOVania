extends TileMap
class_name dentro

const DIALOG: PackedScene = preload("res://Mainframe/dialog.tscn")
onready var jogador: KinematicBody2D = get_node("Player")
onready var audio: AudioStreamPlayer = get_node("AudioStreamPlayer")

onready var jogador2: KinematicBody2D = null

export(Array, String) var dialog_text

func _physics_process(delta):
	if jogador2 == null:
		return
	
	if Input.is_action_just_pressed("Interact") and jogador2 != null:
		get_tree().change_scene("res://Levels/MainLevel.tscn")

func spawn_dialog(dialog_text_list: Array) -> void:
	var dialog: Dialog = DIALOG.instance()
	dialog.dialog_text_list = dialog_text_list
	var _cont: bool = dialog.connect("dialog_finished",self,"on_dialog_finished")
	jogador.add_child(dialog)

func _ready():
	audio.play()
	jogador.freeze(false)
	spawn_dialog(dialog_text)
	
func on_dialog_finished() -> void:
	jogador.freeze(true)


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		jogador2 = body


func _on_Area2D_body_exited(body):
	if body.is_in_group("player"):
		jogador2 = null
