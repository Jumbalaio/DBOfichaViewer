extends Button

onready var popup = get_node("WindowDialog")

func _ready():
	pass 

func _on_count_pressed():
	popup.show()
