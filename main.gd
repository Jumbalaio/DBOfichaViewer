extends Node2D

var both_active = [false, false]

onready var dropdown_1 = get_node("ficha_box_1")
onready var dropdown_2 = get_node("ficha_box_2")

onready var for_1 = get_node("panel_1/icon_anchor/for_text")
onready var des_1 = get_node("panel_1/icon_anchor/des_text")
onready var res_1 = get_node("panel_1/icon_anchor/res_text")
onready var int_1 = get_node("panel_1/icon_anchor/int_text")
onready var spr_1 = get_node("panel_1/icon_anchor/spr_text")

onready var attack_1 = get_node("panel_1/icon_anchor/atacar")
onready var attack_2 = get_node("panel_2/icon_anchor/atacar")

onready var for_2 = get_node("panel_2/icon_anchor/for_text")
onready var des_2 = get_node("panel_2/icon_anchor/des_text")
onready var res_2 = get_node("panel_2/icon_anchor/res_text")
onready var int_2 = get_node("panel_2/icon_anchor/int_text")
onready var spr_2 = get_node("panel_2/icon_anchor/spr_text")

onready var life_1 = get_node("life_1")
var current_life_1
onready var life_bar_1 = get_node("life_bar_1")
var current_life_2
onready var life_bar_2 = get_node("life_bar_2")
onready var life_2 = get_node("life_2")
onready var ki_1 = get_node("ki_1")
onready var ki_2 = get_node("ki_2")
onready var pdl_1 = get_node("panel_1/icon_anchor/power_level")
onready var pdl_2 = get_node("panel_2/icon_anchor/power_level")

onready var roll_1 = get_node("main_panel/roll1")
onready var roll_2 = get_node("main_panel/roll2")
onready var result = get_node("main_panel/result")
onready var reset_1 = get_node("reset_1")
onready var reset_2 = get_node("reset_2")

onready var t_box_1 = get_node("panel_1/transformation_box")
onready var t_box_2 = get_node("panel_2/transformation_box")
onready var s_box_1 = get_node("panel_1/skill_box")
onready var s_box_2 = get_node("panel_2/skill_box")

var box_1 = true

var selected_1 = 0
var selected_2 = 0
var selected_attack_1 = 0
var selected_attack_2 = 0

var nome_1  = ""
var stat_1  = -1
var stats_1  = [-1, -1, -1, -1, -1]
var stats_mod_1  = [-1, -1, -1, -1, -1]
var stats_plus_1  = [0, 0, 0, 0, 0]
var transformacoes_nomes_1  = ["Base"]
var transformacoes_1 = [[-1, -1, -1, -1, -1]]
var ataques_1 = [["f"]]
var ataques_nomes_1 = ["Soco/Chute"]

var nome_2  = ""
var stat_2  = -1
var stats_2  = [-1, -1, -1, -1, -1]
var stats_mod_2  = [-1, -1, -1, -1, -1]
var stats_plus_2  = [0, 0, 0, 0, 0]
var transformacoes_nomes_2  = ["Base"]
var transformacoes_2 = [[-1, -1, -1, -1, -1]]
var ataques_2 = [["f"]]
var ataques_nomes_2 = ["Soco/Chute"]

var stat_index = 0
var file_index = 0
var transformation_index = 1

static func get_dir_files(path: String) -> PoolStringArray:
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
				print("mais um")
				Global.items.append(aux)
				arr += get_dir_files(path.plus_file(subpath))
	return arr

func update_stats(is_box_1, index):
	if is_box_1:
		stats_plus_1  = [0, 0, 0, 0, 0]
		for i in range(5):
			stats_mod_1[i] = int(transformacoes_1[index][i]) * int(stats_1[i])
		
		for i in range(5):
			var aux = 0
			if stats_mod_1[i] > 4:
				aux = 4
				stats_plus_1[i] += 1
				while aux < stats_mod_1[i]:
					if stats_mod_1[i] % 2 == 0:
						stats_plus_1[i] += 1
					aux += 1
					if stats_plus_1[i] == 100:
						break
			elif stats_mod_1[i] == 4:
				 aux = 5
				 stats_plus_1[i] += 1
			else:
				stats_plus_1[i] = 0
		
		print(stats_plus_1)
		
		for_1.text = "FOR:" + str(stats_mod_1[0]) + "(+" + str(stats_plus_1[0]) + ")"
		des_1.text = "DES:" + str(stats_mod_1[1]) + "(+" + str(stats_plus_1[1]) + ")"
		res_1.text = "RES:" + str(stats_mod_1[2]) + "(+" + str(stats_plus_1[2]) + ")"
		int_1.text = "INT:" + str(stats_mod_1[3]) + "(+" + str(stats_plus_1[3]) + ")"
		spr_1.text = "SPR:" + str(stats_mod_1[4]) + "(+" + str(stats_plus_1[4]) + ")"
		pdl_1.text = "PDL:" + str((stats_mod_1[0] * 5) + (stats_mod_1[1] * 2) + (stats_mod_1[2] * 2) + (stats_mod_1[3] * 2) + (stats_mod_1[4] * 5))
		current_life_1 = stats_mod_1[2] * 50
		life_bar_1.max_value = current_life_1
		life_bar_1.value = current_life_1
		life_1.text = "Vida:" + str(stats_mod_1[2] * 50) + "/" + str(stats_mod_1[2] * 50)
		ki_1.text = "Ki:" + str(stats_mod_1[4] * 50) + "/" + str(stats_mod_1[4] * 50)
		
		print(stats_plus_1)
	else:
		stats_plus_2  = [0, 0, 0, 0, 0]
		for i in range(5):
			stats_mod_2[i] = int(transformacoes_2[index][i]) * int(stats_2[i])
		
		for i in range(5):
			var aux = 0
			if stats_mod_2[i] > 4:
				aux = 4
				stats_plus_2[i] += 1
				while aux < stats_mod_2[i]:
					if stats_mod_2[i] % 2 == 0:
						stats_plus_2[i] += 1
					aux += 1
					if stats_plus_2[i] == 100:
						break
			elif stats_mod_2[i] == 4:
				 aux = 5
				 stats_plus_2[i] += 1
			else:
				stats_plus_2[i] = 0
		
		print(stats_plus_2)
		
		for_2.text = "FOR:" + str(stats_mod_2[0]) + "(+" + str(stats_plus_2[0]) + ")"
		des_2.text = "DES:" + str(stats_mod_2[1]) + "(+" + str(stats_plus_2[1]) + ")"
		res_2.text = "RES:" + str(stats_mod_2[2]) + "(+" + str(stats_plus_2[2]) + ")"
		int_2.text = "INT:" + str(stats_mod_2[3]) + "(+" + str(stats_plus_2[3]) + ")"
		spr_2.text = "SPR:" + str(stats_mod_2[4]) + "(+" + str(stats_plus_2[4]) + ")"
		pdl_2.text = "PDL:" + str((stats_mod_2[0] * 5) + (stats_mod_2[1] * 2) + (stats_mod_2[2] * 2) + (stats_mod_2[3] * 2) + (stats_mod_2[4] * 5))
		current_life_2 = stats_mod_2[2] * 50
		life_bar_2.max_value = current_life_2
		life_bar_2.value = current_life_2
		life_2.text = "Vida:" + str(stats_mod_2[2] * 50) + "/" + str(current_life_2)
		ki_2.text = "Ki:" + str(stats_mod_2[4] * 50) + "/" + str(stats_mod_2[4] * 50)
		
		print(stats_plus_2)

func get_ficha(is_box_1):
	var f = File.new()
	if is_box_1:
		f.open(dropdown_1.get_item_text(selected_1).split("]")[0].split("[")[1], File.READ)
	else:
		f.open(dropdown_2.get_item_text(selected_2).split("]")[0].split("[")[1], File.READ)
	var index = 1
	
	if is_box_1:
		stat_index = 0
		file_index = 0
		transformation_index = 1
		transformacoes_1 = [[1, 1, 1, 1, 1]]
		transformacoes_nomes_1 = ["Base"]
		ataques_1 = ["f"]
		ataques_nomes_1 = ["Soco/Chute"]
		s_box_1.clear()
		s_box_1.add_item(ataques_nomes_1[0])
		while not f.eof_reached():
			var x = f.get_line()
			if "Nome" in x:
				nome_1 = x
			if "*" in x:
				stat_1 = x.split(":")[1]
				stats_1[stat_index] = int(stat_1)
				stat_index += 1
			if "@" in x:
				var multiplier = x.split("[")[1].split("\n")[0].split("]")[0].split(",")
				transformacoes_1.append([-1, -1, -1, -1, -1])
				transformacoes_nomes_1.append([])
				for i in range(5):
					transformacoes_1[transformation_index][i] = int(multiplier[i])
				transformacoes_nomes_1[transformation_index] = x.split(":")[0].split("@")[1]
				transformation_index += 1
			index += 1
		f.close()
	else:
		stat_index = 0
		file_index = 0
		transformation_index = 1
		transformacoes_2 = [[1, 1, 1, 1, 1]]
		transformacoes_nomes_2 = ["Base"]
		ataques_2 = ["f"]
		ataques_nomes_2 = ["Soco/Chute"]
		s_box_2.clear()
		s_box_2.add_item(ataques_nomes_2[0])
		while not f.eof_reached():
			var x = f.get_line()
			if "Nome" in x:
				nome_2 = x
			if "*" in x:
				stat_2 = x.split(":")[1]
				stats_2[stat_index] = int(stat_2)
				stat_index += 1
			if "@" in x:
				var multiplier = x.split("[")[1].split("\n")[0].split("]")[0].split(",")
				transformacoes_2.append([-1, -1, -1, -1, -1])
				transformacoes_nomes_2.append([])
				for i in range(5):
					transformacoes_2[transformation_index][i] = int(multiplier[i])
				transformacoes_nomes_2[transformation_index] = x.split(":")[0].split("@")[1]
				transformacoes_nomes_2[transformation_index] = x.split(":")[0].split("@")[1]
				transformation_index += 1
			index += 1
		f.close()

#func attack(is_box_1, index):
#	result = 0
#	if is_box_1:
#		for i in range(ataques_1[index].size()):
#			if ataques_1[index][i] == "f":

func _ready():
	get_dir_files("res://fichas")
	for i in Global.items:
		dropdown_1.add_item(i)
		dropdown_2.add_item(i)
		

func _on_confirm_1_pressed():
	get_ficha(true)
	both_active[0] = true
	if both_active[0] and both_active[1]:
		reset_1.show()
		reset_2.show()
		attack_1.show()
		attack_2.show()
	
	t_box_1.clear()
	for i in range(transformation_index):
		t_box_1.add_item(transformacoes_nomes_1[i])
	update_stats(true, 0)

func _on_confirm_2_pressed():
	get_ficha(false)
	both_active[1] = true
	if both_active[0] and both_active[1]:
		reset_1.show()
		reset_2.show()
		attack_1.show()
		attack_2.show()
	
	t_box_2.clear()
	for i in range(transformation_index):
		t_box_2.add_item(transformacoes_nomes_2[i])
	update_stats(false, 0)

func _on_ficha_box_1_item_selected(index):
	selected_1 = index

func _on_ficha_box_2_item_selected(index):
	selected_2 = index

func _on_transformation_box_1_item_selected(index):
	update_stats(true, index)

func _on_transformation_box_2_item_selected(index):
	update_stats(false, index)

func _on_atacar_1_pressed():
	randomize()
	var random_num = (randi() % 20) + 1
	var random_num_2 = (randi() % 20) + 1
	roll_1.text = nome_1.split(":")[1] + " ataca, tirou " + str(random_num) + " no dado"
	roll_2.text = nome_2.split(":")[1] + " tenta se esquivar, tirou " + str(random_num_2) + " no dado"
	
	if random_num + stats_plus_1[0] > random_num_2 + stats_plus_2[1]:
		var diferenca = (random_num + stats_plus_1[0]) - (random_num_2 + stats_plus_2[1])
		result.text = nome_2.split(":")[1] + " falhou em desviar(" + str(random_num_2) + "+" + str(stats_plus_2[1]) + "), " + nome_1.split(":")[1] + " acertou(" + str(random_num) + "+" + str(stats_plus_1[0]) + "), tirando " + str((stats_mod_1[0] + stats_plus_1[0]) * diferenca) + " de vida"
		current_life_2 -= (stats_mod_1[0] + stats_plus_1[0]) * diferenca
		life_2.text = "Vida:" + str(stats_mod_2[2] * 50) + "/" + str(current_life_2)
		life_bar_2.value = current_life_2
	else:
		result.text =  nome_1.split(":")[1] + " errou"

func _on_atacar_2_pressed():
	randomize()
	var random_num = (randi() % 20) + 1
	var random_num_2 = (randi() % 20) + 1
	roll_2.text = nome_2.split(":")[1] + " ataca, tirou " + str(random_num_2) + " no dado"
	roll_1.text = nome_1.split(":")[1] + " tenta se esquivar, tirou " + str(random_num) + " no dado"
	
	if random_num_2 + stats_plus_2[0] > random_num + stats_plus_1[1]:
		var diferenca = (random_num_2 + stats_plus_2[0]) - (random_num + stats_plus_1[1])
		result.text = nome_1.split(":")[1] + " falhou em desviar(" + str(random_num) + "+" + str(stats_plus_1[1]) + "), " + nome_2.split(":")[1] + " acertou(" + str(random_num_2) + "+" + str(stats_plus_2[0]) + "), tirando " + str((stats_mod_2[0] + stats_plus_2[0]) * diferenca) + " de vida"
		current_life_1 -= (stats_mod_2[0] + stats_plus_2[0]) * diferenca
		life_1.text = "Vida:" + str(stats_mod_1[2] * 50) + "/" + str(current_life_1)
		life_bar_1.value = current_life_1
	else:
		result.text =  nome_2.split(":")[1] + " errou"

func _on_reset_1_pressed():
	current_life_1 = stats_mod_1[2] * 50
	life_1.text = "Vida:" + str(stats_mod_1[2] * 50) + "/" + str(current_life_1)
	life_bar_1.value = current_life_1

func _on_reset_2_pressed():
	current_life_2 = stats_mod_2[2] * 50
	life_2.text = "Vida:" + str(stats_mod_2[2] * 50) + "/" + str(current_life_2)
	life_bar_2.value = current_life_2
