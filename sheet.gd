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

onready var alinhamento = get_node("alignment")
onready var zeni = get_node("zeni")
onready var nome = get_node("nome")

onready var idade = get_node("idade")
onready var altura = get_node("altura")
onready var iniciativa = get_node("iniciativa")
onready var velocidade = get_node("velocidade")
onready var nv = get_node("nv")
onready var xp = get_node("xp")
var menu_panel_inside = false
onready var tween = get_node("Tween")

onready var t_box = get_node("menu_panel/transformation_box_0")
onready var s_box = get_node("menu_panel/skill_box_0")

onready var t_plus = get_node("menu_panel/t_+")
onready var s_plus = get_node("menu_panel/s_+")

onready var error_popup = get_node("incomplete_sheet_popup")
onready var error_label = get_node("incomplete_sheet_popup/error_show")
var error_message = ""

onready var needed_info = [nv, forca, destreza, resistencia, inteligencia, espirito]
var ficha = Global.ficha.duplicate(true)

var null_check = 0
var s_list = ["certa"]
var s_name_list = ["Global.default_attack_name"]
var t_list = []

var terms = ["Força", "Destreza", "Resistencia", "Inteligencia", "Espirito"]
var alignments = ["-", "Lawful/Good", "Chaotic/Good", "Neutral/Good", "True Neutral", "Lawful/Evil", "Chaotic/Evil", "Neutral/Evil"]

func _ready():
	for i in alignments:
		alinhamento.add_item(i)
	for i in terms:
		mod_choice.add_item(i)
	update_lists()

func update_lists():
	t_box.clear()
	s_box.clear()
	for i in s_name_list:
		t_box.add_item(i)
	for i in t_list:
		s_box.add_item(i)

func _on_concluir_pressed():
	for i in range(needed_info.size()):
		if !needed_info[i].text.is_valid_integer():
			error_message = "Stat informado inválido ou incompleto"
			error_label.set_text(error_message)
			error_popup.show()
			return
	if nome.text == "":
		error_message = "Nome incompleto"
		error_label.set_text(error_message)
		error_popup.show() 
		return
	
	var file = File.new()
	file.open("res://fichas/"+ nome.text + ".txt", File.WRITE)
	file.store_string("Nome:" + nome.text + "\n\n")
	file.store_string("?Nivel:" + nv.text + "\n\n")
	file.store_string("$Força:" + forca.text + "\n")
	file.store_string("$Destreza:" + destreza.text + "\n")
	file.store_string("$Resistencia" + resistencia.text + "\n")
	file.store_string("$Inteligencia:" + inteligencia.text + "\n")
	file.store_string("$Espirito:" + espirito.text + "\n\n")
	for i in range(s_list.size()):
		file.store_string("\n@" + s_name_list[i] + ":" + s_list[i])
	file.close()
	
	error_message = "Ficha criada com sucesso"
	error_label.set_text(error_message)
	error_popup.show() 

func _on_s__pressed():
	new_atk_popup.popup()

func _on_cancel_atk_pressed():
	new_atk_popup.hide()

func _on_new_atk_confirmed():
	if atk_name_edit.text != "":
		if ki_cost_edit.text.is_valid_integer():
			var expression = Expression.new()
			var parse = expression.parse(formula.text)
			var result = expression.execute([], self)
			if str(result).is_valid_integer():
				var mod = terms[mod_choice.get_selected_id()][0].to_lower()
				s_name_list.append(atk_name_edit.text)
				s_list.append(mod + "," + ki_cost_edit.text + "£" + formula.text)
				update_lists()
				new_atk_popup.hide()
			else:
				error.text = "Problema com a formula"
		else:
			error.text = "Problema com o custo de ki"
	else:
		error.text = "Nome não informado"

func _process(delta):
	if not menu_panel_inside and Rect2(menu_panel.rect_position, menu_panel.rect_size).has_point(get_global_mouse_position()):
		if menu_panel.rect_position.y != 0:
			tween.stop_all()
			menu_panel_inside = true
			tween.interpolate_property(menu_panel, "rect_position",
				Vector2(0, menu_panel.rect_position.y), Vector2(0, 0), 0.5,
				Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			tween.start()
		print("in")
	if menu_panel_inside and not Rect2(menu_panel.rect_position, menu_panel.rect_size).has_point(get_global_mouse_position()):
		if menu_panel.rect_position.y != -90:
			tween.stop_all()
			menu_panel_inside = false
			tween.interpolate_property(menu_panel, "rect_position",
				Vector2(0, menu_panel.rect_position.y), Vector2(0, -90), 0.5,
				Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			tween.start()
		print("out")

func _on_FileDialog_file_selected(path):
	var image = Image.new()
	image.load(ProjectSettings.globalize_path("res://sheet_image_texture/unknown.png"))
	if image.get_size() != Vector2(2500, 2500):
		print("Imagem fora do padrao de tamanho, reescalando. . .")
		#image.resize(2500, 2500)
	else:
		print("Imagem dentro do padrao de tamanho, carregando. . .")
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture.size
	var aux = get_node("character_image")
	var size = image.get_size()
	var th = 2 #target height
	var tw = 2 #target width
	var scale = Vector2((size.x/(size.x/tw))/50, (size.y/(size.y/th))/50)
	aux.scale = scale
	#image.save_png("res://sheet_image_texture/unknown.png")


func _on_change_image_pressed():
	get_node("FileDialog").popup()
