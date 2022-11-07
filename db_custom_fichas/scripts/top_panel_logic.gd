extends Panel

onready var tween = get_node("Tween")

var menu_panel_inside = false

func painel_superior(until, is_inside):
	if rect_position.y != until:
		tween.stop_all()
		menu_panel_inside = is_inside
		tween.interpolate_property(self, "rect_position",
			Vector2(0, self.rect_position.y), Vector2(0, until), 0.5,
			Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()

func _process(_delta):
	if not menu_panel_inside and Rect2(self.rect_position, self.rect_size).has_point(get_global_mouse_position()):
		painel_superior(0, true)
	if menu_panel_inside and not Rect2(self.rect_position, self.rect_size).has_point(get_global_mouse_position()):
		painel_superior(-90, false)

