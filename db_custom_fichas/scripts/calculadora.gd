extends Button

onready var popup = get_node("WindowDialog")
onready var calculate = get_node("WindowDialog/Button")
onready var calculation = get_node("WindowDialog/LineEdit")
onready var result_label = get_node("WindowDialog/result")

func _on_calc_pressed():
	popup.show()

func _on_Button_pressed():
	var expression = Expression.new()
	expression.parse(calculation.text)
	var result = expression.execute([], self)
	
	result_label.text = "Resultado: " + str(result)
	
