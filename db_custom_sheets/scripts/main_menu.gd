extends Node2D

onready var dragon_ball = get_node("dragon_ball_sprite")
onready var pos_0 = get_node("0")
onready var pos_1 = get_node("1")
onready var pos_2 = get_node("2")
onready var pos_3 = get_node("3")
onready var pos_4 = get_node("4")
onready var pointer_movement = get_node("pointer_tween")
onready var new_sheet_option = get_node("new_sheet_label")
onready var battle_sim_option = get_node("battle_sim_label")
onready var exit_option = get_node("exit_label")

func _ready():
	OS.set_use_vsync(true)
	dragon_ball.position = pos_0.position

func _process(_delta):
	print(String(Engine.get_frames_per_second()))
	dragon_ball.rotate(0.05)

func tween_interpolate(tween_node:Tween, node_to_interpolate, 
	atribute:String, initial, final, time):

	tween_node.interpolate_property(node_to_interpolate, atribute,
		initial, final, time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_node.start()

# Battle_sim
func _on_battle_sim_button_mouse_entered():
	
	tween_interpolate(pointer_movement, dragon_ball, 
	"position", dragon_ball.position, pos_0.position, 0.1)

func _on_battle_sim_button_pressed():
	get_tree().change_scene("res://scenes/battle_sim.tscn")

# New sheet
func _on_new_sheet_button_mouse_entered():
	
	tween_interpolate(pointer_movement, dragon_ball, 
	"position", dragon_ball.position, pos_1.position, 0.1)

func _on_new_sheet_button_pressed():
	Global.is_editing_sheet = false
	Global.is_viewing_sheet = false
	get_tree().change_scene("res://scenes/sheet.tscn")

# Exit
func _on_exit_button_mouse_entered():
	
	tween_interpolate(pointer_movement, dragon_ball, 
	"position", dragon_ball.position, pos_4.position, 0.1)

func _on_exit_button_pressed():
	get_tree().quit()

func _on_edit_button_mouse_entered():
	
	tween_interpolate(pointer_movement, dragon_ball, 
	"position", dragon_ball.position, pos_2.position, 0.1)

func _on_edit_button_pressed():
	Global.is_editing_sheet = false
	Global.is_viewing_sheet = true
	get_tree().change_scene("res://scenes/sheet.tscn")

func _on_real_edit_button_mouse_entered():
	
	tween_interpolate(pointer_movement, dragon_ball, 
	"position", dragon_ball.position, pos_3.position, 0.1)

func _on_real_edit_button_pressed():
	Global.is_editing_sheet = true
	Global.is_viewing_sheet = false
	get_tree().change_scene("res://scenes/sheet.tscn")
