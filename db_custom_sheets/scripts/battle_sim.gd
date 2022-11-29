extends Node2D

# Preparar nodes essenciais
onready var popup = get_node("ConfirmationDialog")
onready var popup_2 = get_node("ConfirmationDialog2")
onready var popup_3 = get_node("ConfirmationDialog3")
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
onready var formula_label = get_node("main_panel/formula")
onready var ki_change_1 = get_node("ki_change_0")
onready var ki_change_2 = get_node("ki_change_1")
onready var st_change_1 = get_node("st_change_0")
onready var st_change_2 = get_node("st_change_1")

var stats_start_string = ["for", "des", "res", "int", "esp"]
var both_active = [false, false]
var ativa = 0

var ficha = [Global.ficha.duplicate(true), Global.ficha.duplicate(true)]

func _ready():
	randomize()
	popup.rect_position = box_position.position
	Global.items = []
	get_dir_files("res://fichas")
	for i in Global.items:
		dropdown_1.add_item(i)
		dropdown_2.add_item(i)

func get_ficha_novo():
	var dropdown = get_node("ficha_box_" + str(ativa))
	var f = File.new()
	
	ficha[ativa] = Global.ficha.duplicate(true)
	
	f.open(dropdown.get_item_text(dropdown.get_selected_id()).split("]")[0].split("[")[1], File.READ)
	ficha[ativa] = str2var(f.get_as_text())
	f.close()

func update_stats_novo():
	var poder_de_luta = get_node("panel_" + str(ativa + 1) + "/icon_anchor/power_level_" + str(ativa))
	var t_box = get_node("panel_"+ str(ativa + 1) +"/transformation_box_" + str(ativa))
	var t_index = t_box.get_selected_id()
	var t_modifier_label = get_node("panel_" + str(ativa + 1) + "/t_modifier")
	
	var damage = ficha[ativa].hp[0] - ficha[ativa].hp[1]
	var ki_used = ficha[ativa].ki[0] - ficha[ativa].ki[1]
	var st_used = ficha[ativa].st[0] - ficha[ativa].st[1]
	
	t_modifier_label.text = ""
	for i in range(5):
		t_modifier_label.text += ficha[ativa].transformacao[t_index].operador[i] + str(ficha[ativa].transformacao[t_index].multiplicador[i]) + ","
		
		var expression = Expression.new()
		var _parse = expression.parse(str(ficha[ativa].stat.normal[i]) + ficha[ativa].transformacao[t_index].operador[i] + str(ficha[ativa].transformacao[t_index].multiplicador[i]))
		var modified_stat = expression.execute([], self)
		
		if modified_stat <= 0:
			modified_stat = 1
		
		var stat_text = get_node("panel_" + str(ativa + 1) + "/icon_anchor/" + stats_start_string[i] + "_text_" + str(ativa))
		
		ficha[ativa].stat.multiplicado[i] = modified_stat
		ficha[ativa].stat.modificador[i] = Global.modifier_calculator(ficha[ativa].stat.multiplicado[i])
		stat_text.text = stats_start_string[i].to_upper() + ":" + str(ficha[ativa].stat.multiplicado[i]) + "(+" + str(ficha[ativa].stat.modificador[i]) + ")"
	
	t_modifier_label.text[-1] = ""
	
	ficha[ativa].hp[0] = ficha[ativa].stat.multiplicado[2] * 50
	ficha[ativa].ki[0] = ficha[ativa].stat.multiplicado[4] * 50
	ficha[ativa].st[0] = ficha[ativa].stat.multiplicado[0] * 25

	change_life(ativa, ficha[ativa].hp[0] - damage)
	change_ki(ativa, ficha[ativa].ki[0] - ki_used)
	change_st(ativa, ficha[ativa].st[0] - st_used)
	
	poder_de_luta.text = "PDL:" + str(Global.power_level_constructor(ficha[ativa]))

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

func update_boxes():
	var life_change = get_node("life_change_" + str(ativa))
	var s_box = get_node("panel_"+ str(ativa + 1) +"/skill_box_" + str(ativa))
	var t_box = get_node("panel_"+ str(ativa + 1) +"/transformation_box_" + str(ativa))
	
	get_ficha_novo()
	both_active[ativa] = true
	life_change.show()
	
	if both_active[0] and both_active[1]:
		reset_1.show()
		reset_2.show()
		attack_1.show()
		attack_2.show()
		life_change_1.show()
		life_change_2.show()
		ki_change_1.show()
		ki_change_2.show()
		st_change_1.show()
		st_change_2.show()
	
	t_box.clear()
	s_box.clear()
	for transformacao in ficha[ativa].transformacao:
		t_box.add_item(transformacao.nome)
	for ataque in ficha[ativa].ataque:
		s_box.add_item(ataque.nome)
	
	update_stats_novo()

func _on_confirm_1_pressed():
	ativa = 0
	update_boxes()

func _on_confirm_2_pressed():
	ativa = 1
	update_boxes()

func calculate_attack(other_sheet, is_first_atk : bool, hit_num : String):
	var s_box = get_node("panel_"+ str(ativa + 1) +"/skill_box_" + str(ativa))
	var s_index = s_box.get_selected_id()
	var ki_cost = int(ficha[ativa].ataque[s_index].custo)
	var st_cost = int(ficha[ativa].ataque[s_index].custo_2)
	var dice_side_amount
	
	if is_first_atk:
		dice_side_amount = 20
	else:
		dice_side_amount = int(ficha[ativa].ataque[s_box.get_selected_id()].lados_consecutivo)
	
	result.text += "\n-------------Rolagem " + hit_num + " (d" + str(dice_side_amount) + ")---------------\n\n"
	
	if ki_cost > ficha[ativa].ki[1] and is_first_atk:
		result.text += "Ki insuficiente"
		return false
	if st_cost > ficha[ativa].st[1] and is_first_atk:
		result.text += "Stamina insuficiente"
		return false
	
	var atk_roll = (randi() % dice_side_amount) + 1
	var def_roll = (randi() % 20) + 1
	var atk_formula = ficha[ativa].ataque[s_index].formula
	var dice_to_roll = ficha[ativa].ataque[s_index].stat
	var frase = ["",""]
	
	var atk_button_group = get_node("panel_"+ str(ativa + 1) + "/neutro_" + str(ativa)).group
	var def_button_group = get_node("panel_"+ str(ativa + 1) + "/desvio_" + str(ativa)).group

	if is_first_atk:
		change_ki(ativa, ficha[ativa].ki[1] - int(ki_cost))
		change_st(ativa, ficha[ativa].st[1] - int(st_cost))
	
	var atk_button = str(atk_button_group.get_pressed_button()).split(":")[0]
	var def_button = str(def_button_group.get_pressed_button()).split(":")[0]
	var atk_roll_modded = atk_roll + ficha[ativa].stat.modificador[dice_to_roll]
	var def_roll_modded
	var second_roll = (randi() % dice_side_amount) + 1
	var second_roll_modded = second_roll + ficha[ativa].stat.modificador[dice_to_roll]
	
	var def_index = 1
	if def_button == "desvio_" + str(ativa):
		def_index = 1
		def_roll_modded = def_roll + ficha[other_sheet].stat.modificador[def_index]
	else:
		def_index = 2
		def_roll_modded = def_roll + ficha[other_sheet].stat.modificador[def_index]
	
	roll_1.text += "\n----Rolagem " + hit_num + " (d" + str(dice_side_amount) + ")----\n\n"
	
	if atk_button == "vantagem_" + str(ativa) and is_first_atk:
		roll_1.text += ficha[ativa].nome + " ataca com vantagem, tirou " + str(atk_roll) + " e " + str(second_roll) + " no dado"
		if second_roll_modded > atk_roll_modded: 
			atk_roll = second_roll
			atk_roll_modded = second_roll_modded
	elif atk_button == "desvantagem_" + str(ativa) and is_first_atk:
		roll_1.text += ficha[ativa].nome + " ataca com desvantagem, tirou " + str(atk_roll) + " e " + str(second_roll) + " no dado"
		if second_roll_modded < atk_roll_modded: 
			atk_roll = second_roll
			atk_roll_modded = second_roll_modded
	else:
		roll_1.text += ficha[ativa].nome + " ataca, tirou " + str(atk_roll) + " no dado"
	
	roll_2.text += "\n----Rolagem " + hit_num + " (d20)----\n\n"
	
	if def_button == "desvio_" + str(ativa):
		roll_2.text += ficha[other_sheet].nome + " tenta se esquivar, tirou " + str(def_roll) + " no dado"
		frase[0] = " errou."
		frase[1] = " desviar"
	else:
		roll_2.text += ficha[other_sheet].nome + " tenta bloquear, tirou " + str(def_roll) + " no dado"
		frase[0] = " teve seu ataque bloqueado."
		frase[1] = " se defender"
	
	if atk_roll_modded <= def_roll_modded:
		result.text += ficha[ativa].nome + frase[0]
		return false
	
	var dif = atk_roll_modded - def_roll_modded
	
	var completed_formula = Global.formula_term_converter(atk_formula, ficha[ativa], dif)
	
	var expression = Expression.new()
	
	var _parse = expression.parse(completed_formula)
	
	var damage_delt = expression.execute([], self)
	
	var final_formula_text = formula_constructor(atk_formula)
	formula_label.text = final_formula_text
	result.text += ficha[other_sheet].nome + " falhou em" + frase[1] + "(" + str(def_roll) + "+" + str(ficha[other_sheet].stat.modificador[def_index]) + "), " + ficha[ativa].nome + " acertou(" + str(atk_roll) + "+" + str(ficha[ativa].stat.modificador[dice_to_roll]) + "), tirando " + str(damage_delt) + " de hp"
	
	change_life(other_sheet, ficha[other_sheet].hp[1] - damage_delt)
	
	return true

# Procura termos e os substitui para criar uma formula mais legivel #
func formula_constructor(atk_formula):
	var terms = ["Força", "Destreza", "Resistencia", "Inteligencia", "Espirito"]
	
	for i in range(terms.size()):
		atk_formula = atk_formula.replace(terms[i].left(3), terms[i])
	atk_formula = atk_formula.replace("DN", "Dano de nível")
	atk_formula = atk_formula.replace("DIF", "Diferença")
	
	return atk_formula

# Listeners abaixo #
func _on_reset_1_pressed():
	change_life(0, ficha[0].hp[0])
	change_ki(0, ficha[0].ki[0])
	change_st(0, ficha[0].st[0])

func _on_reset_2_pressed():
	change_life(1, ficha[1].hp[0])
	change_ki(1, ficha[1].ki[0])
	change_st(1, ficha[1].st[0])

func _on_scan_folder_pressed():
	var path_index = [dropdown_1.get_selected_id(), dropdown_2.get_selected_id()]
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
		for j in Global.items:
			if j == Global.items[path_index[i]] and both_active[i]:
				ativa = i
				get_ficha_novo()
				t_box[i].clear()
				s_box[i].clear()
				for k in range(ficha[i].transformacao.size()):
					t_box[i].add_item(ficha[i].transformacao[k].nome)
				for k in range(ficha[i].ataque.size()):
					s_box[i].add_item(ficha[i].ataque[k].nome)
				update_stats_novo()

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
		change_life(ativa, int(edit_life.text))

func change_life(s_index, value):
	var bar_node = get_node("life_bar_" + str(s_index))
	var bar_text = get_node("life_" + str(s_index))
	
	ficha[s_index].hp[1] = value
	bar_text.text = "hp:" + str(ficha[s_index].hp[0]) + "/" + str(ficha[s_index].hp[1])
	bar_node.max_value = ficha[s_index].hp[0]
	bar_node.value = ficha[s_index].hp[1]

func change_ki(s_index, value):
	var bar_node = get_node("ki_bar_" + str(s_index))
	var bar_text = get_node("ki_" + str(s_index))
	
	ficha[s_index].ki[1] = value
	bar_text.text = "ki:" + str(ficha[s_index].ki[0]) + "/" + str(ficha[s_index].ki[1])
	bar_node.max_value = ficha[s_index].ki[0]
	bar_node.value = ficha[s_index].ki[1]

func change_st(s_index, value):
	var bar_node = get_node("st_bar_" + str(s_index))
	var bar_text = get_node("st_" + str(s_index))
	
	ficha[s_index].st[1] = value
	bar_text.text = "st:" + str(ficha[s_index].st[0]) + "/" + str(ficha[s_index].st[1])
	bar_node.max_value = ficha[s_index].st[0]
	bar_node.value = ficha[s_index].st[1]

func _on_atacar_0_pressed():
	ativa = 0
	result.text = ""
	roll_1.text = ""
	roll_2.text = ""
	var hits = int(ficha[ativa].ataque[s_box_1.get_selected_id()].quantidade_de_hits)
	if calculate_attack(1, true, "1") and hits > 1:
		for i in range(hits - 1):
			calculate_attack(1, false, str(i + 2))

func _on_atacar_1_pressed():
	ativa = 1
	result.text = ""
	roll_1.text = ""
	roll_2.text = ""
	var hits = int(ficha[ativa].ataque[s_box_2.get_selected_id()].quantidade_de_hits)
	if calculate_attack(0, true, "1") and hits > 1:
		for i in range(hits - 1):
			calculate_attack(0, false, str(i + 2))

func _on_Button_pressed():
	get_tree().change_scene("res://scenes/main_menu.tscn")

func _on_ki_change_0_pressed():
	popup_2.window_title = "Cetar ki de " + ficha[0].nome
	popup_2.rect_position = box_position.position
	ativa = 0
	popup_2.show()

func _on_ki_change_1_pressed():
	popup_2.window_title = "Cetar ki de " + ficha[1].nome
	popup_2.rect_position = box_position.position
	ativa = 1
	popup_2.show()

func _on_ConfirmationDialog2_confirmed():
	var node = get_node("ConfirmationDialog2/LineEdit")
	if node.text.is_valid_integer():
		change_ki(ativa, int(node.text))

func _on_transformation_box_0_item_selected(index):
	ativa = 0
	update_stats_novo()

func _on_transformation_box_1_item_selected(index):
	ativa = 1
	update_stats_novo()

func _on_st_change_0_pressed():
	popup_3.window_title = "Cetar stamina de " + ficha[0].nome
	popup_3.rect_position = box_position.position
	ativa = 0
	popup_3.show()

func _on_st_change_1_pressed():
	popup_3.window_title = "Cetar stamina de " + ficha[1].nome
	popup_3.rect_position = box_position.position
	ativa = 1
	popup_3.show()

func _on_ConfirmationDialog3_confirmed():
	var node = get_node("ConfirmationDialog3/LineEdit")
	if node.text.is_valid_integer():
		change_st(ativa, int(node.text))
