extends Node2D

var items = []

var modifier_cap = 10
var default_attack_name = "Soco/Chute"
var default_attack_formula = "f,0£(f*D)"
var default_transformation_name = "Base"
var default_transformation_modifier = [1, 1, 1, 1, 1]


var transformacao = {
"nome":default_transformation_name,
"multiplicador":default_transformation_modifier
}

var ataque = {
"nome":default_attack_name,
"formula":default_attack_formula
}

var stat = {
"normal":[1, 1, 1, 1, 1],
"multiplicado":[1, 1, 1, 1, 1],
"modificador":[0, 0, 0, 0, 0]
}

var item = {
"item_nome":"",
"item_quant":0
}

var ficha = {
"nome":"",
"altura":"",
"nivel":1,
"xp":[0,0],
"stat":stat,
"transformacao":[transformacao],
"inventario":[item],
"ataque":[ataque],
"vida":[50, 50],
"ki":[50, 50],
"dano_de_nivel":2,
"imagem_url":"res://sheet_image_texture/unknown.png"
}

func modifier_calculator():
	pass

func power_level_constructor(sheet:Dictionary):
	var multipliers = [5, 2, 2, 2, 5]
	var power_level = 0
	for i in range(5):
		power_level += sheet.stat.multiplicado[i] * multipliers[i]
	return power_level
