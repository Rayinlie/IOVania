extends Control
class_name Dialog

signal dialog_finished

onready var text: RichTextLabel = get_node("Background/Text")

var can_interact: bool = false

var current_dialog: int = 0
var dialog_text_list: Array = []

func _ready():
	show_dialog()
	
func _process(delta):
	if can_interact == true and Input.is_action_just_pressed("Interact"):
		current_dialog += 1
		can_interact = false
		show_dialog()
	
func show_dialog() -> void:
	if current_dialog > dialog_text_list.size() - 1:
		emit_signal("dialog_finished")
		queue_free()
		return
	text.percent_visible = 0
	text.text = dialog_text_list[current_dialog]
	while text.percent_visible < 1:
		text.percent_visible += get_process_delta_time()
		yield(get_tree(),"idle_frame")

	can_interact = true


