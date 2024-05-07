extends Area2D
class_name CharacterAttackArea

onready var character: KinematicBody2D = get_parent()

func _ready() -> void:
	connect("area_entered",self,"on_area entered")
	
	connect("body_entered",self,"on_body_entered")
	
func on_area_entered(_area) -> void:
	pass
		
func on_body_entered(_body) -> void:
	pass
