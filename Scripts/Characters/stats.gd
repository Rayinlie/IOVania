extends Node2D
class_name CharacterStats

var max_health: int

onready var character: KinematicBody2D = get_parent()
onready var sprite: Sprite = get_node("%Texture")

export(int) var health
export(Array) var attack_range

func _ready() -> void:
	max_health = health


func update_health(type: String, value: int, target_position = Vector2.ZERO) -> void:
	match type:
		'Heal':
			health = clamp(health + value, 0, max_health)
			
		'Damage':
			health = clamp(health + value, 0, max_health)
			
			if health == 0:
				character.kill()
				return
			
			character.apply_knockback(target_position)

func get_attack() -> int:
	return randi() % attack_range.max() + attack_range.min()
