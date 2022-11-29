extends Button

onready var roll_popup = get_node("WindowDialog")
onready var quant = get_node("WindowDialog/quant")
onready var sides = get_node("WindowDialog/sides")
onready var mod = get_node("WindowDialog/mod")
onready var historico = get_node("WindowDialog/VScrollBar/VBoxContainer/historico")

var roll_count = 0

func _ready():
	randomize()

func _on_roll_pressed():
	roll_popup.show()

func _on_roll_button_pressed():
	if !mod.text.is_valid_integer() or !sides.text.is_valid_integer() or !quant.text.is_valid_integer():
		return
	
	roll_count += 1
	historico.text += "\n---    Rolagem " + str(roll_count) + " (" + sides.text + " lados)   ---  \n"
	for _i in range(int(quant.text)):
		var roll = (randi() % int(sides.text)) + 1
		var espacamento = "                "
		historico.text += espacamento + str(roll) + " + " + mod.text + " = " + str(roll + int(mod.text)) + "  \n"
	historico.text += "\n"

func _on_clear_pressed():
	roll_count = 0
	historico.text = ""
