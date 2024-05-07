extends Control

onready var mana_bar: ProgressBar = get_node("BarsControll/ManaBar")
onready var health_bar: ProgressBar = get_node("BarsControll/HealthBar")
onready var exp_bar: ProgressBar = get_node("BarsControll/ExpBar")


var Health: int = 33
var MaxHealth: int = 100
var Mana: int = 20
var MaxMana: int = 20

func _ready():
	if player.is_in_group("player"):
		Health = player.health
		MaxHealth = player.max_health
		Mana = player.mana
		MaxMana = player.max_mana
	update_health_bar()
	update_mana_bar()

func update_health_bar():
	health_bar.value = (Health * 100) / MaxHealth
	#health_bar.

func update_mana_bar():
	health_bar.value = (Mana * 100) / MaxMana
