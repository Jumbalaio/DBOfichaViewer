extends Node2D

var items = []

var modifier_cap = 10

var default_attack_name = "Soco/Chute"
var default_attack_formula = "(f*D)"

var default_transformation_name = "Base"
var default_transformation_modifier = [1, 1, 1, 1, 1]

var transformacao = {
"nome":default_transformation_name,
"multiplicador":default_transformation_modifier
}

var ataque = {
"nome":"Soco/Chute",
"formula":"(f*D)",
"stat":0,
"custo":0,
"ataque_de_ki":false
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
"alinhamento":"-",
"zeni":0,
"stat":stat,
"hp":[50, 50],
"ki":[50, 50],
"dano_de_nivel":2,
"imagem_url":"res://images/unknown.png",
"transformacao":[transformacao],
"inventario":[],
"ataque":[ataque],
"descricao":""
}

func modifier_calculator(s):
	if not s.is_valid_integer() or int(s) <= 0:
		return "?"
	
	var aux = 1
	var mod = 0
	s = int(s)
	while aux <= s:
		if (aux % 3 == 0) and (aux <= s):
			mod += 1
		aux += 1
		if mod == modifier_cap:
			return mod
	return mod

func power_level_constructor(sheet:Dictionary):
	var multipliers = [5, 2, 2, 2, 5]
	var power_level = 0
	for i in range(5):
		power_level += sheet.stat.multiplicado[i] * multipliers[i]
	return power_level

func dano_de_nivel_calculator(nivel):
	if !nivel.is_valid_integer() or int(nivel) <= 0:
		return "?"
	
	var dano_de_nivel = 2
	var count = 0
	for i in range(int(nivel)):
		if count == 2:
			dano_de_nivel += 2
			count = 0
		count += 1
	return dano_de_nivel
