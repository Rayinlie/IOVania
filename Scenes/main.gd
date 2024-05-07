extends Node2D

onready var newgame_button: Button = get_node("Control/NewGame")
onready var credits_button: Button = get_node("Control3/Credits")
onready var quit_button: Button = get_node("Control2/Quit")
onready var sound: AudioStreamPlayer = get_node("AudioStreamPlayer")

func _ready():
	play_music()

func _on_NewGame_pressed():
	
	get_tree().change_scene("res://Levels/Dentro.tscn")

func _on_Quit_pressed():
	get_tree().quit()

func _on_Credits_pressed():
	pass # Replace with function body.


func _on_AudioStreamPlayer_finished():
	play_music()

func play_music():
	sound.set_bus("res://Assets/Sounds/Musics/By_Starlight_full_track.mp3")
	sound.playing = true
