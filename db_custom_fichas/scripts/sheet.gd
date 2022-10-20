extends Node2D

onready var hp_txt = get_node("hp_txt")
onready var ki_txt = get_node("ki_txt")
onready var sp_txt = get_node("st_txt")
onready var for_txt = get_node("for_txt")
onready var des_txt = get_node("des_txt")
onready var res_txt = get_node("res_txt")
onready var int_txt = get_node("int_txt")
onready var esp_txt = get_node("esp_txt")
onready var forca = get_node("for")
onready var destreza = get_node("des")
onready var resistencia = get_node("res")
onready var inteligencia = get_node("int")
onready var espirito = get_node("esp")
onready var new_atk_popup = get_node("new_atk")
onready var mod_choice = get_node("new_atk/Panel/mod_choice_box")
onready var ki_cost_edit = get_node("new_atk/Panel/ki_cost")
onready var atk_name_edit = get_node("new_atk/Panel/atk_name")
onready var formula = get_node("new_atk/Panel/formula")
onready var error = get_node("new_atk/Panel/error_message")
onready var menu_panel = get_node("menu_panel")
onready var character_portrait = get_node("character_image")
onready var dano_de_nivel = get_node("dano_de_nivel")
onready var delete_atk = get_node("confirm_atk_delete")
onready var new_transform_popup = get_node("new_transform")

onready var alinhamento = get_node("alignment")
onready var zeni = get_node("zeni")
onready var nome = get_node("nome")

onready var t_popup_name = get_node("new_transform/Panel/transform_name")

onready var idade = get_node("idade")
onready var altura = get_node("altura")
onready var nv = get_node("nv")
onready var tween = get_node("Tween")

onready var t_box = get_node("transformation_box_0")
onready var s_box = get_node("skill_box_0")

onready var t_plus = get_node("menu_panel/t_+")
onready var s_plus = get_node("menu_panel/s_+")

onready var error_popup = get_node("incomplete_sheet_popup")
onready var error_label = get_node("incomplete_sheet_popup/error_show")
onready var iniciativa = get_node("iniciativa")

var ficha = Global.ficha.duplicate(true)
var sheet_info_check = [false, false, false, false, false, false, false]
var terms = ["Força", "Destreza", "Resistencia", "Inteligencia", "Espirito"]
var alignments = ["-", "Lawful/Good", "Chaotic/Good", "Neutral/Good", "True Neutral", "Lawful/Evil", "Chaotic/Evil", "Neutral/Evil"]
var menu_panel_inside = false
var creating_atk = false
var creating_transform = false
var atk_to_remove = false
var t_popup_nodes = []
 
func _ready():
	t_popup_nodes = get_popup_transform_box_nodes()
	set_portrait("res://images/unknown.png")
	for i in alignments:
		alinhamento.add_item(i)
	for i in terms:
		mod_choice.add_item(i)
	update_boxes()

func update_boxes():
	t_box.clear()
	s_box.clear()
	for transformacao in ficha.transformacao:
		t_box.add_item(transformacao.nome)
	for ataque in ficha.ataque:
		s_box.add_item(ataque.nome)

func _on_concluir_pressed():
	for valid in sheet_info_check:
		if !valid:
			error_label.set_text("Campo importante incompleto ou valor inserido invalido")
			error_popup.show()
			return
	
	var file = File.new()
	
	if file.file_exists("res://fichas/"+ nome.text + ".txt"):
		error_popup.set_text("")
		error_label.set_text("Uma ficha com o nome \"" + ficha.nome + "\" ja existe")
		error_popup.show()
		return
		
	file.open("res://fichas/"+ nome.text + ".txt", File.WRITE)
	file.store_string(var2str(ficha))
	file.close()
	
	error_label.set_text("Ficha criada com sucesso")
	error_popup.popup()

func _on_cancel_atk_pressed():
	new_atk_popup.hide()

func check_atk_boxes():
	if atk_name_edit.text == "":
		error.text = "Nome não informado"
		return false
	if !ki_cost_edit.text.is_valid_integer():
		error.text = "Problema com o custo de ki"
		return false
		
	var expression = Expression.new()
	expression.parse(formula.text)
	var result = expression.execute([], self)
	
	if !str(result).is_valid_integer():
		error.text = "Problema com a formula"
		return false
	return true

func s_popup_box_content_to_sheet(index):
		ficha.ataque[index].nome = atk_name_edit.text
		ficha.ataque[index].formula = formula.text
		ficha.ataque[index].custo = ki_cost_edit.text
		ficha.ataque[index].stat = mod_choice.get_selected_id()

func _on_new_atk_confirmed():
	if !check_atk_boxes():
		return
	
	if creating_atk:
		ficha.ataque.append(Global.ataque.duplicate(true))
		s_popup_box_content_to_sheet(-1)
	else:
		var atk_index = s_box.get_selected_id()
		s_popup_box_content_to_sheet(atk_index)
	update_boxes()

func painel_superior(until, is_inside):
	if menu_panel.rect_position.y != until:
		tween.stop_all()
		menu_panel_inside = is_inside
		tween.interpolate_property(menu_panel, "rect_position",
			Vector2(0, menu_panel.rect_position.y), Vector2(0, until), 0.5,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()

func _process(_delta):
	if not menu_panel_inside and Rect2(menu_panel.rect_position, menu_panel.rect_size).has_point(get_global_mouse_position()):
		painel_superior(0, true)
	if menu_panel_inside and not Rect2(menu_panel.rect_position, menu_panel.rect_size).has_point(get_global_mouse_position()):
		painel_superior(-90, false)

func set_portrait(path):
	var image = Image.new()
	var texture = ImageTexture.new()
	
	image.load(path)
	texture.create_from_image(image)
	
	var sizeto = Vector2(130,130)
	var size = texture.get_size()
	var scale_factor = sizeto / size
	var scale = scale_factor
	
	character_portrait.set_texture(texture)
	character_portrait.scale = scale

func _on_FileDialog_file_selected(path):
	ficha.imagem_url = path
	set_portrait(path)

func _on_change_image_pressed():
	get_node("FileDialog").popup()

func stat_change_handler(text, stat_label, other_label, stat_key_word, stat_to_modify, stat_index):
	var modifier = str(Global.modifier_calculator(text))
	stat_label.text = stat_key_word + "\t\t\t\t\t(+" + modifier + ")"
	if modifier.is_valid_integer():
		
		sheet_info_check[stat_index] = true
		if stat_to_modify != null:
			var stat_modified = int(text) * 50
			
			ficha.stat.normal[stat_index] = int(text)
			ficha[stat_to_modify] = [stat_modified, stat_modified]
			other_label.text = stat_to_modify.to_upper() + "   " + str(stat_modified) + "/" + str(stat_modified) 
		else:
			ficha.stat.normal[stat_index] = int(text)
	else:
		
		sheet_info_check[stat_index] = false
		if stat_to_modify != null:
			ficha.stat.normal[stat_index] = 1
			ficha[stat_to_modify] = [50, 50]
			other_label.text = stat_to_modify.to_upper()
		else:
			ficha.stat.normal[stat_index] = 1
	return modifier

func _on_for_text_changed(new_text):
	stat_change_handler(new_text, for_txt, null, "FOR", null, 0)

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
	dano_de_nivel.text = "DANO DE NIVEL: " + str(Global.dano_de_nivel_calculator(new_text)) 
	if dano_de_nivel.text[-1] != "?":
		ficha.nivel = int(new_text)
		sheet_info_check[6] = true
	else:
		nv.text = ""
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
	if new_text.is_valid_integer():
		ficha.zeni = int(new_text)
	else:
		zeni.text = ""
		ficha.zeni = ""

func _on_idade_text_changed(new_text):
	if new_text.is_valid_integer():
		ficha.idade = int(new_text)
	else:
		idade.text = ""
		ficha.idade = ""

func _on_atk_edit_pressed():
	creating_atk = false
	
	var atk_index = s_box.get_selected_id()
	if atk_index == 0:
		error_popup.set_text("")
		error_popup.set_text("Não é possivel modificar o ataque padrao")
		error_popup.popup()
		return
	
	atk_name_edit.text = ficha.ataque[atk_index].nome
	ki_cost_edit.text = ficha.ataque[atk_index].custo
	formula.text = ficha.ataque[atk_index].formula
	mod_choice.select(ficha.ataque[atk_index].stat)
	
	new_atk_popup.window_title = "Editando ataque"
	new_atk_popup.popup()

func _on_confirm_atk_delete_confirmed():
	if atk_to_remove:
		ficha.ataque.remove(s_box.get_selected_id())
	else:
		ficha.transformacao.remove(t_box.get_selected_id())
	update_boxes()

func _on_atk_delete_pressed():
	if  s_box.get_selected_id() == 0:
		error_popup.set_text("Não é possivel deletar o ataque padrão")
		error_popup.popup()
		return
	
	delete_atk.dialog_text = "Deletar o ataque \"" + s_box.get_item_text(s_box.get_selected_id()) + "\"?"
	atk_to_remove = true
	delete_atk.popup()

func _on_atk_add_pressed():
	creating_atk = true
	atk_name_edit.text = ""
	mod_choice.select(0)
	ki_cost_edit.text = ""
	formula.text = ""
	new_atk_popup.window_title = "Criando novo ataque"
	new_atk_popup.popup()

func get_popup_transform_box_nodes():
	var node_list = []
	for i in range(5):
		node_list.append(get_node("new_transform/Panel/" + str(i)))
	return node_list

func t_popup_box_content_to_sheet(index):
	var modificador = []
	for i in range(5):
		modificador.append(int(t_popup_nodes[i].text))
	ficha.transformacao[index].nome = t_popup_name.text
	ficha.transformacao[index].multiplicador = modificador
	print(ficha.transformacao)

func _on_new_transform_confirmed():
	if !check_transform_boxes():
		return

	if creating_transform:
		ficha.transformacao.append(Global.transformacao.duplicate(true))
		t_popup_box_content_to_sheet(-1)
	else:
		var transform_index = t_box.get_selected_id()
		t_popup_box_content_to_sheet(transform_index)
	update_boxes()

func check_transform_boxes():
	if t_popup_name.text == "":
		return false
	for i in range(5):
		if !t_popup_nodes[i].text.is_valid_integer():
			return false
	return true

func _on_transform_add_pressed():
	creating_transform = true
	t_popup_name.text = ""
	for i in range(5):
		t_popup_nodes[i].text = ""
	new_transform_popup.popup()

func _on_transform_edit_pressed():
	if t_box.get_selected_id() == 0:
		error_popup.set_text("Não é possivel alterar a transformação padrão")
		error_popup.popup()
		return
	creating_transform = false
	var transform_index = t_box.get_selected_id()
	t_popup_name.text = ficha.transformacao[transform_index].nome
	for i in range(5):
		t_popup_nodes[i].text = str(ficha.transformacao[transform_index].multiplicador[i])
	new_transform_popup.popup()

func _on_transform_delete_pressed():
	if t_box.get_selected_id() == 0:
		error_popup.set_text("Não é possivel deletar a transformação padrão")
		error_popup.popup()
		return
		
	delete_atk.dialog_text = "Deletar a transformação \"" + t_box.get_item_text(t_box.get_selected_id()) + "\"?"
	atk_to_remove = false
	delete_atk.popup()
