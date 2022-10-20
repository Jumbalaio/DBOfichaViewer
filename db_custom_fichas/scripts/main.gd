extends Node2D

# Preparar nodes essenciais
onready var popup = get_node("ConfirmationDialog")
onready var formula = get_node("main_panel/formula")
onready var desvio_1 = get_node("panel_1/desvio_0")
onready var bloqueio_1 = get_node("panel_1/bloqueio_0")
onready var dropdown_1 = get_node("ficha_box_0")
onready var dropdown_2 = get_node("ficha_box_1")
onready var attack_1 = get_node("panel_1/atacar_0")
onready var attack_2 = get_node("panel_2/atacar_1")
onready var life_1 = get_node("life_0")
onready var life_2 = get_node("life_1")
onready var life_change_1 = get_node("life_change_0")
onready var life_change_2 = get_node("life_change_1")
onready var life_bar_1 = get_node("life_bar_0")
onready var life_bar_2 = get_node("life_bar_1")
onready var edit_life = get_node("ConfirmationDialog/LineEdit")
onready var ki_1 = get_node("ki_0")
onready var ki_2 = get_node("ki_1")
onready var ki_bar_1 = get_node("ki_bar_0")
onready var ki_bar_2 = get_node("ki_bar_1")
onready var roll_1 = get_node("main_panel/roll_0")
onready var roll_2 = get_node("main_panel/roll_1")
onready var result = get_node("main_panel/result")
onready var reset_1 = get_node("reset_0")
onready var reset_2 = get_node("reset_1")
onready var t_box_1 = get_node("panel_1/transformation_box_0")
onready var t_box_2 = get_node("panel_2/transformation_box_1")
onready var s_box_1 = get_node("panel_1/skill_box_0")
onready var s_box_2 = get_node("panel_2/skill_box_1")
onready var box_position = get_node("box_position")

var both_active = [false, false]
var stats_start_string = ["for", "des", "res", "int", "esp"]
var selected = [0, 0]
var ativa
var em_uso = [0, 0]
var attack_index = 0
var t_index = 1
var path_index = [0, 0]

var ficha = [Global.ficha.duplicate(true), Global.ficha.duplicate(true)]

func _ready():
	randomize()
	popup.rect_position = box_position.position
	get_dir_files("res://fichas")
	for i in Global.items:
		dropdown_1.add_item(i)
		dropdown_2.add_item(i)

func get_ficha_novo():
	var dropdown = get_node("ficha_box_" + str(ativa))
	var s_box = get_node("panel_" + str(ativa + 1) + "/transformation_box_" + str(ativa))
	var f = File.new()
	var stat_index = 0

	t_index = 1
	attack_index = 1
	
	ficha[ativa] = Global.ficha.duplicate(true)
	
	s_box.clear()
	s_box.add_item(ficha[ativa].ataque[0].nome)
	em_uso[ativa] = 0
	
	f.open(dropdown.get_item_text(selected[ativa]).split("]")[0].split("[")[1], File.READ)
	while not f.eof_reached():
		var x = f.get_line()
		
		if "Nome" in x:
			ficha[ativa].nome = x.split(":")[1]
			var name = get_node("panel_" + str(ativa + 1) + "/nome_" + str(ativa))
			name.text = ficha[ativa].nome
		if "?" in x:
			var name = get_node("panel_" + str(ativa + 1) + "/nome_" + str(ativa))
			ficha[ativa].nivel = int(x.split(":")[1])
			name.text += "\t\tNv:" + str(ficha[ativa].nivel)
		if "$" in x:
			var stat = x.split(":")[1]
			ficha[ativa].stat.normal[stat_index] = int(stat)
			stat_index += 1
		if "@" in x:
			var multiplier = x.split("[")[1].split("\n")[0].split("]")[0].split(",")
			ficha[ativa].transformacao.append({"nome":"Base","multiplicador":[1, 1, 1, 1, 1]})
			for j in range(5):
				ficha[ativa].transformacao[t_index].multiplicador[j] = int(multiplier[j])
			ficha[ativa].transformacao[t_index].nome = x.split(":")[0].split("@")[1]
			t_index += 1
		if "#" in x:
			var a = Global.ataque.duplicate()
			a.nome = x.split(":")[0].split("#")[1]
			a.formula = x.split(":")[1]
			ficha[ativa].ataque.append(a)
			attack_index += 1
	f.close()

func update_stats_novo(index):
	var life_bar = get_node("life_bar_" + str(ativa))
	var ki_bar = get_node("ki_bar_" + str(ativa))
	var life_text = get_node("life_" + str(ativa))
	var ki_text = get_node("ki_" + str(ativa))
	ficha[ativa].stat.modificador = [0, 0, 0, 0, 0]
	
	for i in range(5):
		var stat_normal = ficha[ativa].stat.normal[i]
		var multiplicador_t = ficha[ativa].transformacao[index].multiplicador[i]
		ficha[ativa].stat.multiplicado[i] = stat_normal * multiplicador_t
	
	for i in range(5):
		var aux = 1
		while aux <= ficha[ativa].stat.multiplicado[i]:
			if (aux % 3 == 0) and (aux <= ficha[ativa].stat.multiplicado[i]):
				ficha[ativa].stat.modificador[i] += 1
			aux += 1
			if ficha[ativa].stat.modificador[i] == Global.modifier_cap + 1:
				break
	
	for i in range(5):
		var stat_text = get_node("panel_" + str(ativa + 1) + "/icon_anchor/" + stats_start_string[i] + "_text_" + str(ativa))
		stat_text.text = stats_start_string[i].to_upper() + ":" + str(ficha[ativa].stat.multiplicado[i]) + "(+" + str(ficha[ativa].stat.modificador[i]) + ")"
	
	var poder_de_luta = get_node("panel_" + str(ativa + 1) + "/icon_anchor/power_level_" + str(ativa))
	poder_de_luta.text = "PDL:" + str(Global.power_level_constructor(ficha[ativa]))
	
	ficha[ativa].hp[0] = ficha[ativa].stat.multiplicado[2] * 50
	ficha[ativa].hp[1] = ficha[ativa].hp[0]
	ficha[ativa].ki[0] = ficha[ativa].stat.multiplicado[4] * 50
	ficha[ativa].ki[1] = ficha[ativa].ki[0]

	life_bar.max_value = ficha[ativa].hp[0]
	life_bar.value = ficha[ativa].hp[1]
	life_text.text = "hp:" + str(ficha[ativa].hp[0]) + "/" + str(ficha[ativa].hp[1])
	
	ki_bar.max_value = ficha[ativa].ki[0]
	ki_bar.value = ficha[ativa].ki[1]
	ki_text.text = "Ki:" + str(ficha[ativa].ki[0]) + "/" + str(ficha[ativa].ki[1])

func get_dir_files(path: String) -> PoolStringArray:
	var arr: PoolStringArray
	var dir := Directory.new()
	dir.open(path)
	
	if dir.file_exists(path):
		arr.append(path)
	
	else:
		dir.list_dir_begin(true,  true)
		while(true):
			var subpath := dir.get_next()
			if subpath.empty():
				break
			var aux = String(get_dir_files(path.plus_file(subpath)))
			if aux.ends_with(".txt]"):
				Global.items.append(aux)
				arr += get_dir_files(path.plus_file(subpath))
	return arr

func _on_confirm_1_pressed():
	path_index[0] = selected[0]
	ativa = 0
	get_ficha_novo()
	both_active[0] = true
	life_change_1.show()
	if both_active[0] and both_active[1]:
		reset_1.show()
		reset_2.show()
		attack_1.show()
		attack_2.show()
		life_change_1.show()
		life_change_2.show()
	
	t_box_1.clear()
	s_box_1.clear()
	for i in range(t_index):
		t_box_1.add_item(ficha[ativa].transformacao[i].nome)
	for i in range(attack_index):
		s_box_1.add_item(ficha[ativa].ataque[i].nome)
	update_stats_novo(0)

func _on_confirm_2_pressed():
	path_index[1] = selected[1]
	ativa = 1
	get_ficha_novo()
	both_active[1] = true
	life_change_2.show()
	if both_active[0] and both_active[1]:
		reset_1.show()
		reset_2.show()
		attack_1.show()
		attack_2.show()
	
	t_box_2.clear()
	s_box_2.clear()
	for i in range(t_index):
		t_box_2.add_item(ficha[ativa].transformacao[i].nome)
	for i in range(attack_index):
		s_box_2.add_item(ficha[ativa].ataque[i].nome)
	update_stats_novo(0)

func calculate_attack(other_sheet):
	var skill_text = ficha[ativa].ataque[em_uso[ativa]].formula.split("£")
	var cost = int(skill_text[0].split(",")[1])
	
	if cost > ficha[ativa].ki[1]:
		result.text = "Ki insuficiente"
		return
	
	var atk_roll = (randi() % 20) + 1
	var def_roll = (randi() % 20) + 1
	var mod_index = 0
	var skill_expression = skill_text[1]
	var dice_to_roll = skill_text[0].split(",")[0]
	var frase = ["",""]
	
	var ki = get_node("ki_" + str(ativa))
	var ki_bar = get_node("ki_bar_" + str(ativa))
	var atk_button_group = get_node("panel_"+ str(ativa + 1) + "/neutro_" + str(ativa)).group
	var def_button_group = get_node("panel_"+ str(ativa + 1) + "/desvio_" + str(ativa)).group
	var life_bar = get_node("life_bar_" + str(other_sheet))
	var life = get_node("life_" + str(other_sheet))
	
	ficha[ativa].ki[1] -= int(cost)
	ki.text = "Ki:" + str(ficha[ativa].ki[0]) + "/" + str(ficha[ativa].ki[1])
	ki_bar.value = ficha[ativa].ki[1]
	
	for i in range(5):
		if dice_to_roll == stats_start_string[i][0]:
			mod_index = i
		
	var atk_roll_modded = atk_roll + ficha[ativa].stat.modificador[mod_index]
	var def_roll_modded = def_roll + ficha[other_sheet].stat.modificador[1]
	var atk_button = str(atk_button_group.get_pressed_button()).split(":")[0]
	var def_button = str(def_button_group.get_pressed_button()).split(":")[0]
	var second_roll = (randi() % 20) + 1
	var second_roll_modded = second_roll + ficha[ativa].stat.modificador[mod_index]
	print(atk_button)
	
	if atk_button == "vantagem_" + str(ativa):
		roll_1.text = ficha[ativa].nome + " ataca com vantagem, tirou " + str(atk_roll) + " e " + str(second_roll) + " no dado"
		if second_roll_modded > atk_roll_modded: 
			atk_roll = second_roll
			atk_roll_modded = second_roll_modded
	elif atk_button == "desvantagem_" + str(ativa):
		roll_1.text = ficha[ativa].nome + " ataca com desvantagem, tirou " + str(atk_roll) + " e " + str(second_roll) + " no dado"
		if second_roll_modded < atk_roll_modded: 
			atk_roll = second_roll
			atk_roll_modded = second_roll_modded
	else:
		roll_1.text = ficha[ativa].nome + " ataca, tirou " + str(atk_roll) + " no dado"
	
	if def_button == "desvio_" + str(ativa):
		roll_2.text = ficha[other_sheet].nome + " tenta se esquivar, tirou " + str(def_roll) + " no dado"
		frase[0] = " errou."
		frase[1] = " desviar"
	else:
		roll_2.text = ficha[other_sheet].nome + " tenta bloquear, tirou " + str(def_roll) + " no dado"
		frase[0] = " teve seu ataque bloqueado."
		frase[1] = " se defender"
	if atk_roll_modded <= def_roll_modded:
		result.text = ficha[ativa].nome + frase[0]
		return
	
	for i in range(5):
		skill_expression = skill_expression.replace(stats_start_string[i][0], str(ficha[ativa].stat.normal[i]))
	skill_expression = skill_expression.replace("D", str(atk_roll_modded - def_roll_modded) + "\n")
	skill_expression = skill_expression.replace("n", str(ficha[ativa].nivel))
	
	var expression = Expression.new()
	var parse = expression.parse(skill_expression)
	var damage_delt = expression.execute([], self)
	var formula_text = skill_text[1]
	var final_formula_text = ""
	
	for i in formula_text:
		final_formula_text += formula_constructor(i)
		
	formula.text = final_formula_text
	result.text = ficha[other_sheet].nome + " falhou em" + frase[1] + "(" + str(def_roll) + "+" + str(ficha[other_sheet].stat.modificador[1]) + "), " + ficha[ativa].nome + " acertou(" + str(atk_roll) + "+" + str(ficha[ativa].stat.modificador[mod_index]) + "), tirando " + str(damage_delt) + " de hp"
	
	ficha[other_sheet].hp[1] -= damage_delt
	life.text = "hp:" + str(ficha[other_sheet].hp[0]) + "/" + str(ficha[other_sheet].hp[1])
	life_bar.value = ficha[other_sheet].hp[1]

# Procura termos e os substitui para criar uma formula mais legivel #
func formula_constructor(letter):
	var terms = ["Força", "Destreza", "Resistencia", "Inteligencia", "Espirito"]
	
	for i in range(terms.size()):
		if letter == stats_start_string[i][0]:
			return terms[i]
	if letter == "n":
		return "Nivel"
	if letter == "D":
		return "Diferença"
	return letter

# Listeners abaixo #
func _on_ficha_box_1_item_selected(index):
	selected[0] = index

func _on_ficha_box_2_item_selected(index):
	selected[1] = index

func _on_transformation_box_1_item_selected(index):
	ativa = 0
	update_stats_novo(index)

func _on_transformation_box_2_item_selected(index):
	ativa = 1
	update_stats_novo(index)

func reset_life(index):
	var life_bar = get_node("life_bar_" + str(index))
	var ki_bar =  get_node("ki_bar_" + str(index))
	var life = get_node("life_" + str(index))
	var ki = get_node("ki_" + str(index)) 
	
	ficha[index].hp[1] = ficha[index].hp[0]
	life.text = "hp:" + str(ficha[index].hp[0]) + "/" + str(ficha[index].hp[1])
	life_bar.value = ficha[index].hp[1]
	
	ficha[index].ki[1] = ficha[index].ki[0]
	ki.text = "Ki:" + str(ficha[index].ki[0]) + "/" + str(ficha[index].ki[1])
	ki_bar.value = ficha[index].ki[1]
	

func _on_reset_1_pressed():
	reset_life(0)

func _on_reset_2_pressed():
	reset_life(1)

func _on_scan_folder_pressed():
	var t_box = [t_box_1, t_box_2]
	var s_box = [s_box_1, s_box_2]
	dropdown_1.clear()
	dropdown_2.clear()
	Global.items.clear()
	get_dir_files("res://fichas")
	
	for i in Global.items:
		dropdown_1.add_item(i)
		dropdown_2.add_item(i)
	
	for i in range(2):
		var index = 0
		for j in Global.items:
			if j == Global.items[path_index[i]] and both_active[i]:
				ativa = i
				selected[i] = index
				get_ficha_novo()
				t_box[i].clear()
				s_box[i].clear()
				for k in range(t_index):
					t_box[i].add_item(ficha[i].transformacao[k].nome)
				for k in range(attack_index):
					s_box[i].add_item(ficha[i].ataque[k].nome)
				update_stats_novo(0)
			index += 1
	
	selected[0] = 0
	selected[1] = 0

func _on_life_change_1_pressed():
	popup.window_title = "Cetar hp de " + ficha[0].nome
	popup.rect_position = box_position.position
	ativa = 0
	popup.show()

func _on_life_change_2_pressed():
	popup.window_title = "Cetar hp de " + ficha[1].nome
	popup.rect_position = box_position.position
	ativa = 1
	popup.show()

func _on_ConfirmationDialog_1_confirmed():
	if edit_life.text.is_valid_integer():
		var life_bar = get_node("life_bar_" + str(ativa))
		var life = get_node("life_" + str(ativa))
		ficha[ativa].hp[1] = int(edit_life.text)
		life.text = life.text.split("/")[0] + ("/" + edit_life.text)
		life_bar.value = int(ficha[ativa].hp[1])

func _on_skill_box_1_item_selected(index):
	em_uso[0] = index

func _on_skill_box_2_item_selected(index):
	em_uso[1] = index

func _on_atacar_0_pressed():
	ativa = 0
	calculate_attack(ativa + 1)

func _on_atacar_1_pressed():
	ativa = 1
	calculate_attack(ativa - 1)
