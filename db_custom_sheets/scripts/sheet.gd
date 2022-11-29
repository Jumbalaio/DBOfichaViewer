extends Node2D

onready var hp_txt = get_node("hp_txt")
onready var ki_txt = get_node("ki_txt")
onready var st_txt = get_node("st_txt")
onready var for_txt = get_node("for_txt")
onready var des_txt = get_node("des_txt")
onready var res_txt = get_node("res_txt")
onready var int_txt = get_node("int_txt")
onready var esp_txt = get_node("esp_txt")
onready var cha_txt = get_node("cha_txt")

onready var somatorio = get_node("somatoria")

onready var return_button = get_node("menu_panel/voltar")
onready var complete_edit = get_node("menu_panel/concluir_edição")
onready var confirm_quit_popup = get_node("confirm_quit")

onready var pdl = get_node("poder_de_luta")

onready var sheet_dropdown = get_node("menu_panel/sheet_choose_anchor/sheets")
onready var choose_anchor = get_node("menu_panel/sheet_choose_anchor")

onready var mod_choice = get_node("new_atk/Panel/mod_choice_box")
onready var ki_cost_edit = get_node("new_atk/Panel/ki_cost")
onready var st_cost_edit = get_node("new_atk/Panel/st_cost")
onready var atk_name_edit = get_node("new_atk/Panel/atk_name")
onready var formula = get_node("new_atk/Panel/formula")
onready var menu_panel = get_node("menu_panel")
onready var character_portrait = get_node("character_image")
onready var delete_atk = get_node("confirm_atk_delete")

onready var new_item_popup = get_node("new_item")
onready var error_popup = get_node("incomplete_sheet_popup")
onready var new_atk_popup = get_node("new_atk")
onready var new_transform_popup = get_node("new_transform")

onready var qnt_rolagem = get_node("new_atk/Panel/qnt_rolagem")
onready var qnt_lados = get_node("new_atk/Panel/qnt_lados")

onready var alinhamento = get_node("alignment")
onready var zeni = get_node("zeni")
onready var nome = get_node("nome")
onready var idade = get_node("idade")
onready var altura = get_node("altura")
onready var nv = get_node("nv")
onready var iniciativa = get_node("iniciativa")
onready var descricao = get_node("descricao")
onready var dano_de_nivel = get_node("dano_de_nivel")

onready var overlay = get_node("overlay")
onready var overlay_message = get_node("Label2")

onready var t_popup_name = get_node("new_transform/Panel/transform_name")
onready var tween = get_node("Tween")

onready var t_box = get_node("transformation_box_0")
onready var s_box = get_node("skill_box_0")
onready var i_box = get_node("inventory_box_0")

onready var concluir = get_node("menu_panel/concluir")
onready var change_image = get_node("change_image")

onready var item_name = get_node("new_item/Panel/item_name")
onready var item_quant = get_node("new_item/Panel/quantidade")

onready var cha_lineedit = get_node("5")

onready var delete_sheet = get_node("menu_panel/delete_sheet")

onready var delete_sheet_popup = get_node("confirm_delete_sheet")

onready var invent_anchor = get_node("invent_anchor")
onready var transform_anchor = get_node("transform_anchor")
onready var attack_anchor = get_node("attack_anchor")
onready var status = get_node("status")

var sheet_info_check = [true, true, true, true, true, false, true]
var terms = ["Força", "Destreza", "Resistencia", "Inteligencia", "Espirito"]
var alignments = ["-", "Lawful/Good", "Chaotic/Good", "Neutral/Good", "Chaotic/Neutral", "True Neutral","Lawful/Neutral", "Lawful/Evil", "Chaotic/Evil", "Neutral/Evil"]

var creating_new = false
var atk_to_remove = false
var transform_to_remove = false

var t_popup_nodes = []

var is_editing_sheet = false

var ficha = Global.ficha.duplicate(true)
 
func _ready():
	Global.items = []
	sheet_dropdown_update()
	
	if Global.is_viewing_sheet:
		status.text = "VISUALIZANDO"
		change_image.disabled = true
		delete_sheet.show()
		overlay.show()
		overlay_message.text = "Escolha a ficha a visualizar no menu acima"
		choose_anchor.show()
		concluir.hide()
		complete_edit.hide()
		
		toggle_editable(false)
	elif Global.is_editing_sheet:
		status.text = "EDITANDO"
		change_image.disabled = false
		delete_sheet.hide()
		overlay.show()
		overlay_message.text= "Escolha a ficha a editar no menu acima"
		choose_anchor.show()
		concluir.hide()
		complete_edit.hide()
		
		toggle_editable(true)
	else:
		status.text = "CRIANDO"
		change_image.disabled = false
		delete_sheet.hide()
		overlay.hide()
		overlay_message.text = ""
		choose_anchor.hide()
		concluir.show()
		complete_edit.hide()
		
		toggle_editable(true)
	
	t_popup_nodes = get_popup_transform_box_nodes()
	set_portrait("res://images/unknown.png")
	for i in alignments:
		alinhamento.add_item(i)
	for i in terms:
		mod_choice.add_item(i)
	update_boxes()
	pdl.text = "PODER DE LUTA: " + str(Global.power_level_constructor(ficha))

func update_boxes():
	t_box.clear()
	s_box.clear()
	i_box.clear()
	
	for transformacao in ficha.transformacao:
		t_box.add_item(transformacao.nome)
	for ataque in ficha.ataque:
		s_box.add_item(ataque.nome)
	for item in ficha.inventario:
		i_box.add_item(str(item.item_quant) + " X " + item.item_nome)

func is_sheet_valid():
	for valid in sheet_info_check:
		if !valid:
			error_popup.dialog_text = "Campo importante incompleto ou valor inserido invalido"
			error_popup.show()
			return false
	
	var file = File.new()
	if !is_editing_sheet:
		if file.file_exists("res://fichas/"+ nome.text + ".txt") and !Global.is_editing_sheet:
			error_popup.dialog_text = "Uma ficha com o nome \"" + ficha.nome + "\" ja existe"
			error_popup.show()
			return false
		
	ficha.descricao = descricao.text

	file.open("res://fichas/"+ nome.text + ".txt", File.WRITE)
	file.store_string(var2str(ficha))
	file.close()
	
	get_tree().change_scene("res://scenes/main_menu.tscn")


func _on_concluir_pressed():
	is_sheet_valid()

func _on_cancel_atk_pressed():
	new_atk_popup.hide()

func check_atk_boxes():
	if atk_name_edit.text == "":
		error_popup.dialog_text = "Nome não informado"
		return false
	if !ki_cost_edit.text.is_valid_integer():
		error_popup.dialog_text = "Problema com o custo de ki"
		return false
	if !st_cost_edit.text.is_valid_integer():
		error_popup.dialog_text = "Problema com o custo de stamina"
		return false
	
	for i in range(5):
		formula.text = formula.text.replacen(terms[i].left(3), terms[i].left(3).to_lower())
	formula.text = formula.text.replacen("dif", "DIF")
	formula.text = formula.text.replacen("dn", "DN")
	formula.text = formula.text.replacen(" ", "")
	
	var expression = Expression.new()
	expression.parse(Global.formula_term_converter(formula.text, ficha, -1))
	var result = expression.execute([], self)
	
	if expression.has_execute_failed():
		error_popup.dialog_text = "Problema com a formula"
		return false
	return true

func s_popup_box_content_to_sheet(index):
		ficha.ataque[index].nome = atk_name_edit.text
		ficha.ataque[index].formula = formula.text
		ficha.ataque[index].custo = ki_cost_edit.text
		ficha.ataque[index].custo_2 = st_cost_edit.text
		ficha.ataque[index].quantidade_de_hits = qnt_rolagem.get_item_text(qnt_rolagem.get_selected_id())
		ficha.ataque[index].lados_consecutivo = qnt_lados.get_item_text(qnt_lados.get_selected_id())
		ficha.ataque[index].stat = mod_choice.get_selected_id()

func _on_new_atk_confirmed():
	if !check_atk_boxes():
		error_popup.popup()
		return
	
	if creating_new:
		ficha.ataque.append(Global.ataque.duplicate(true))
		s_popup_box_content_to_sheet(-1)
	else:
		var atk_index = s_box.get_selected_id()
		s_popup_box_content_to_sheet(atk_index)
	new_item_popup.hide()
	update_boxes()
	new_atk_popup.hide()

func set_portrait(path):
	var image = Image.new()
	var texture = ImageTexture.new()
	
	image.load(ProjectSettings.globalize_path(path))
	texture.create_from_image(image)
	
	var sizeto = Vector2(130,130)
	var size = texture.get_size()
	var scale_factor = sizeto / size
	var scale = scale_factor
	character_portrait.texture = texture
	
	character_portrait.scale = scale

func _on_FileDialog_file_selected(path):
	ficha.imagem_url = path
	set_portrait(path)

func _on_change_image_pressed():
	get_node("FileDialog").popup()

func change_stat_sum_text():
	for i in range(5):
		if !sheet_info_check[i]:
			return false
	return true

func stat_change_handler(text, stat_label, other_label, stat_key_word, stat_to_modify, stat_index):
	var box = get_node(str(stat_index))
	var modifier = str(Global.modifier_calculator(text))
	var old_position = box.get_cursor_position()
	
	if box.text.is_valid_integer():
		sheet_info_check[stat_index] = true
		box.set_cursor_position(old_position)
		
		ficha.stat.normal[stat_index] = int(text)
		ficha.stat.multiplicado[stat_index] = ficha.stat.normal[stat_index]
		ficha.stat.modificador[stat_index] = int(modifier)
		pdl.text = "PODER DE LUTA: " + str(Global.power_level_constructor(ficha))
		
		if stat_to_modify != null:
			var stat_modified = int(text) * 50
			ficha[stat_to_modify] = [stat_modified, stat_modified]
			other_label.text = stat_to_modify.to_upper() + "   " + str(stat_modified) + "/" + str(stat_modified) 
			
		stat_label.text = stat_key_word + "\t\t\t\t\t(+" + modifier + ")"
	else:
		if box.text != "":
			sheet_info_check[stat_index] = true
			box.text[old_position - 1] = ""
			box.set_cursor_position(old_position - 1)
			modifier = str(Global.modifier_calculator(box.text))
		else:
			pdl.text = "PODER DE LUTA: ?"
			sheet_info_check[stat_index] = false
			modifier = "?"
		
		stat_label.text = stat_key_word + "\t\t\t\t\t(+" + modifier + ")"
		
		if stat_to_modify != null:
			other_label.text = stat_to_modify.to_upper()
	
	if change_stat_sum_text():
		var somatoria_valor = 0
		for i in range(5):
			somatoria_valor+= ficha.stat.normal[i]
		somatorio.text = "SOMATORIA: " + str(somatoria_valor)
	else:
		somatorio.text = "SOMATORIA: ?"
	return modifier

func _on_for_text_changed(value):
	stat_change_handler(value, for_txt, null, "FOR", null, 0)
	if str(value) != "":
		ficha.st[0] = int(value) * 25
		ficha.st[1] = ficha.st[0]
		st_txt.text = "ST     " + str(ficha.st[0]) + "/" +  str(ficha.st[1])
	else:
		ficha.st[0] = 25
		ficha.st[1] = ficha.st[0]
		st_txt.text = "ST     ?/?"

func _on_des_text_changed(new_text):
	var mod = stat_change_handler(new_text, des_txt, null, "DES", null, 1)
	iniciativa.text = "INICIAT   +" + mod

func _on_res_text_changed(new_text):
	stat_change_handler(new_text, res_txt, hp_txt, "RES", "hp", 2)

func _on_int_text_changed(new_text):
	stat_change_handler(new_text, int_txt, null, "INT", null, 3)

func _on_esp_text_changed(new_text):
	stat_change_handler(new_text, esp_txt, ki_txt, "ESP", "ki", 4)

func _on_nv_text_changed(new_text):
	if fix_box(nv, new_text, true):
		ficha.nv = int(nv.text)
		ficha.dano_de_nivel = int(Global.dano_de_nivel_calculator(nv.text))
		dano_de_nivel.text = "DANO DE NIVEL: " + str(ficha.dano_de_nivel) 
		sheet_info_check[6] = true
	else:
		ficha.nv = 1
		ficha.dano_de_nivel = 2
		dano_de_nivel.text = "DANO DE NIVEL: ?" 
		sheet_info_check[6] = false

func _on_nome_text_changed(new_text):
	if !new_text.empty():
		
		ficha.nome = new_text
		sheet_info_check[5] = true
	else:
		sheet_info_check[5] = false

func _on_alignment_item_selected(index):
	ficha.alinhamento = alinhamento.get_item_text(index)

func _on_zeni_text_changed(new_text):
	if fix_box(zeni, new_text, false):
		ficha.zeni = int(zeni.text)
	else:
		ficha.zeni = 0

func _on_idade_text_changed(new_text):
	if fix_box(idade, new_text, true):
		ficha.idade = int(idade.text)
	else:
		ficha.idade = 20

func _on_atk_edit_pressed():
	creating_new = false
	var sides_index = {"2":0,"3":1,"4":2,"6":3,"8":4,"10":5,"12":6,"20":7,"100":8}
	var hits_index = {"1":0,"2":1,"3":2,"4":3,"5":4,"6":5}
	var atk_index = s_box.get_selected_id()
	if atk_index == 0:
		error_popup.set_text("")
		error_popup.set_text("Não é possivel modificar o ataque padrao")
		error_popup.popup()
		return
	
	if int(ficha.ataque[atk_index].quantidade_de_hits) > 1:
		qnt_lados.disabled = false
	else:
		qnt_lados.disabled = true
	
	atk_name_edit.text = ficha.ataque[atk_index].nome
	ki_cost_edit.text = ficha.ataque[atk_index].custo
	st_cost_edit.text = ficha.ataque[atk_index].custo_2
	formula.text = ficha.ataque[atk_index].formula
	mod_choice.select(ficha.ataque[atk_index].stat)
	qnt_rolagem.select(hits_index[ficha.ataque[atk_index].quantidade_de_hits])
	qnt_lados.select(sides_index[ficha.ataque[atk_index].lados_consecutivo])
	
	new_atk_popup.window_title = "Editando ataque"
	new_atk_popup.popup()

func _on_confirm_atk_delete_confirmed():
	if atk_to_remove:
		ficha.ataque.remove(s_box.get_selected_id())
	elif transform_to_remove:
		ficha.transformacao.remove(t_box.get_selected_id())
	else:
		ficha.inventario.remove(i_box.get_selected_id())
	update_boxes()

func _on_atk_delete_pressed():
	if  s_box.get_selected_id() == 0:
		error_popup.set_text("Não é possivel deletar o ataque padrão")
		error_popup.popup()
		return
	
	delete_atk.dialog_text = "Deletar o ataque \"" + s_box.get_item_text(s_box.get_selected_id()) + "\"?"
	atk_to_remove = true
	transform_to_remove = false
	delete_atk.window_title = "Deletando ataque"
	delete_atk.popup()

func _on_atk_add_pressed():
	creating_new = true
	atk_name_edit.text = ""
	mod_choice.select(0)
	qnt_rolagem.select(0)
	qnt_lados.select(0)
	qnt_lados.disabled = true
	ki_cost_edit.text = ""
	st_cost_edit.text = ""
	formula.text = ""
	new_atk_popup.window_title = "Criando ataque"
	new_atk_popup.popup()

func get_popup_transform_box_nodes():
	var node_list = []
	for i in range(5):
		node_list.append(get_node("new_transform/Panel/" + str(i)))
	return node_list

func t_popup_box_content_to_sheet(index):
	var modificador = []
	for i in range(5):
		var op_box = get_node("new_transform/Panel/operations/" + str(i)) 
		ficha.transformacao[index].operador[i] = op_box.get_item_text(op_box.get_selected_id())
		modificador.append(int(t_popup_nodes[i].text))
	
	ficha.transformacao[index].nome = t_popup_name.text
	ficha.transformacao[index].multiplicador = modificador

func _on_new_transform_confirmed():
	if !check_transform_boxes():
		return

	if creating_new:
		ficha.transformacao.append(Global.transformacao.duplicate(true))
		t_popup_box_content_to_sheet(-1)
	else:
		var transform_index = t_box.get_selected_id()
		t_popup_box_content_to_sheet(transform_index)
	new_item_popup.hide()
	update_boxes()
	new_transform_popup.hide()

func check_transform_boxes():
	if t_popup_name.text == "":
		return false
	for i in range(5):
		if !t_popup_nodes[i].text.is_valid_integer():
			return false
	return true

func _on_transform_add_pressed():
	creating_new = true
	t_popup_name.text = ""
	for i in range(5):
		var op_box = get_node("new_transform/Panel/operations/" + str(i))
		op_box.select(0)
		t_popup_nodes[i].text = ""
	new_transform_popup.window_title = "Criando transformação"
	new_transform_popup.popup()

func _on_transform_edit_pressed():
	if t_box.get_selected_id() == 0:
		error_popup.set_text("Não é possivel alterar a transformação padrão")
		error_popup.popup()
		return
	
	creating_new = false
	var transform_index = t_box.get_selected_id()
	t_popup_name.text = ficha.transformacao[transform_index].nome
	var op_index = {"*": 0, "+": 1, "-": 2}
	for i in range(5):
		var op_box = get_node("new_transform/Panel/operations/" + str(i))
		op_box.select(op_index[ficha.transformacao[transform_index].operador[i]])
		t_popup_nodes[i].text = str(ficha.transformacao[transform_index].multiplicador[i])
	new_transform_popup.window_title = "Editando transformação"
	new_transform_popup.popup()

func _on_transform_delete_pressed():
	if t_box.get_selected_id() == 0:
		error_popup.set_text("Não é possivel deletar a transformação padrão")
		error_popup.popup()
		return
		
	delete_atk.dialog_text = "Deletar a transformação \"" + t_box.get_item_text(t_box.get_selected_id()) + "\"?"
	atk_to_remove = false
	transform_to_remove = true
	delete_atk.window_title = "Deletando transformação"
	delete_atk.popup()

func _on_invent_add_pressed():
	creating_new = true
	item_name.text = ""
	item_quant.text = ""
	new_item_popup.window_title = "Criando item"
	new_item_popup.popup()

func _on_new_item_confirmed():
	if item_name.text == "" or !item_quant.text.is_valid_integer():
		error_popup.dialog_text = "Erro: Nome vazio ou quantidade inválida"
		error_popup.popup()
		return
	
	if creating_new:
		ficha.inventario.append(Global.item.duplicate(true))
		ficha.inventario[-1].item_nome = item_name.text
		ficha.inventario[-1].item_quant = item_quant.text
	else:
		var item_index = i_box.get_selected_id()
		ficha.inventario[item_index].item_nome = item_name.text
		ficha.inventario[item_index].item_quant = item_quant.text
	new_item_popup.hide()
	update_boxes()

func inventory_empty():
	if ficha.inventario.empty():
		error_popup.dialog_text = "Inventario vazio"
		error_popup.popup()
		return true
	return false

func _on_invent_delete_pressed():
	if inventory_empty():
		return
	
	atk_to_remove = false
	transform_to_remove = false
	delete_atk.window_title = "Deletando item"
	delete_atk.popup()

func _on_invent_edit_pressed():
	if inventory_empty():
		return
	
	creating_new = false
	var item_index = i_box.get_selected_id()
	var name = ficha.inventario[item_index].item_nome
	var quant = ficha.inventario[item_index].item_quant
	item_name.text = name
	item_quant.text = quant
	new_item_popup.window_title = "Editando item"
	new_item_popup.popup()

func _on_altura_text_changed(new_text):
	var replaced_comma = new_text.replace(",", ".")
	var old_position = altura.get_cursor_position()
	
	if replaced_comma.is_valid_float():
		altura.text = replaced_comma
		ficha.altura = float(altura.text)
		altura.set_cursor_position(old_position)
	elif altura.text != "":
		altura.text[altura.get_cursor_position() - 1] = ""
		ficha.altura = ""
		altura.set_cursor_position(old_position - 1)

func sheet_dropdown_update():
	get_dir_files("res://fichas/")
	for sheet in Global.items:
		sheet_dropdown.add_item(sheet)

func _on_sheet_choose_pressed():
	overlay.hide()
	overlay_message.text = ""
	if Global.is_editing_sheet:
		complete_edit.show()
		choose_anchor.hide()
	sheet_info_check = [true, true, true, true, true, true, true]
	var f = File.new()
	
	ficha = Global.ficha.duplicate(true)
	
	var new_path = sheet_dropdown.get_item_text(sheet_dropdown.get_selected_id())
	
	new_path[0] = ""
	new_path[-1] = ""
	
	f.open(new_path, File.READ)
	ficha = str2var(f.get_as_text())
	f.close()
	
	update_ficha()
	var image = Image.new()
	var texture = ImageTexture.new()

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

func update_ficha():
	set_portrait(ficha.imagem_url)
	update_boxes()
	
	nome.text = ficha.nome
	
	for i in range(alignments.size()):
		if ficha.alinhamento == alignments[i]:
			alinhamento.select(i)
	
	zeni.text = str(ficha.zeni)
	altura.text = str(ficha.altura)
	idade.text = str(ficha.idade)
	
	_on_for_text_changed(ficha.stat.normal[0])
	_on_des_text_changed(ficha.stat.normal[1])
	_on_res_text_changed(ficha.stat.normal[2])
	_on_int_text_changed(ficha.stat.normal[3])
	_on_esp_text_changed(ficha.stat.normal[4])
	
	cha_lineedit.text = str(ficha.stat.carisma)
	cha_txt.text = "CHA\t\t\t\t\t(+" + str(ficha.stat.carisma_modificador) + ")"
	
	for i in range(5):
		get_node(str(i)).text = str(ficha.stat.normal[i])
	
	nv.text = str(ficha.nivel)
	descricao.text = ficha.descricao
	dano_de_nivel.text = "DANO DE NIVEL: " + str(Global.dano_de_nivel_calculator(str(ficha.nivel)))
	iniciativa.text = "INICIAT   +" + str(ficha.stat.modificador[1])


func _on_quit_no_save_pressed():
	get_tree().change_scene("res://scenes/main_menu.tscn")

func toggle_editable(is_editable : bool):
		for i in range(6):
			get_node(str(i)).editable = is_editable
		
		if !Global.is_viewing_sheet and !Global.is_editing_sheet:
			nome.editable = is_editable
		zeni.editable = is_editable
		altura.editable = is_editable
		idade.editable = is_editable
		nv.editable = is_editable
		
		if is_editable:
			invent_anchor.show()
			attack_anchor.show()
			transform_anchor.show()
			
			descricao.readonly = false
			alinhamento.disabled = false
		else:
			nome.editable = false
			invent_anchor.hide()
			attack_anchor.hide()
			transform_anchor.hide()
			
			descricao.readonly = true
			alinhamento.disabled = true

func _on_voltar_pressed():
	confirm_quit_popup.popup()

func _on_concluir_edio_pressed():
	is_sheet_valid()

func _on_confirm_quit_confirmed():
	get_tree().change_scene("res://scenes/main_menu.tscn")

func _on_delete_sheet_pressed():
	if sheet_dropdown.get_item_count() <= 1:
		error_popup.dialog_text = "O programa precisa de pelo menos uma ficha registrada"
		error_popup.popup()
		return
	delete_sheet_popup.dialog_text = "Deletar a ficha \"" +  sheet_dropdown.get_item_text(sheet_dropdown.get_selected_id()) + "\"?"
	delete_sheet_popup.popup()

func _on_confirm_delete_sheet_confirmed():
	var dir = Directory.new()
	var path = sheet_dropdown.get_item_text(sheet_dropdown.get_selected_id())
	path[-1] = ""
	path[0] = ""
	dir.remove(path)
	
	get_tree().change_scene("res://scenes/main_menu.tscn")

func fix_box(node : LineEdit, new_text : String, box_value_is_integer : bool):
	var old_position = node.get_cursor_position()
	
	if box_value_is_integer and new_text.is_valid_integer():
		node.set_cursor_position(old_position)
		
		return true
	elif !box_value_is_integer and new_text.replace(",", ".").is_valid_float():
		node.text = node.text.replace(",", ".")
		node.set_cursor_position(old_position)
		
		return true
	if node.text != "":
		node.text[node.get_cursor_position() - 1] = ""
		node.set_cursor_position(old_position - 1)
		
		return true
	return false

func _on_5_text_changed(new_text):
	
	if fix_box(cha_lineedit, new_text, true):
		var new_value = int(cha_lineedit.text)
		
		ficha.stat.carisma = new_value
		ficha.stat.carisma_modificador = Global.modifier_calculator(new_value)
		cha_txt.text = "CHA\t\t\t\t\t(+" + str(ficha.stat.carisma_modificador) + ")"
	else:
		ficha.stat.carisma = 1
		ficha.stat.carisma_modificador = 0
		cha_txt.text = "CHA\t\t\t\t\t(+?)"

func _on_qnt_rolagem_item_selected(index):
	if qnt_rolagem.get_item_text(index) == "1":
		qnt_lados.disabled = true
	else:
		qnt_lados.disabled = false
