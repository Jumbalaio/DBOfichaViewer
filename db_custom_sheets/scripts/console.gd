extends Control

onready var console_input = get_node("console_edit")
onready var console_output = get_node("console_box")

func _ready():
	console_input.grab_focus()

func _on_console_edit_text_entered(new_text):
	var expression = Expression.new()
	var _parse = expression.parse(new_text)
	expression.execute()
