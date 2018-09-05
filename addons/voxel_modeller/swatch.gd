tool
extends ColorRect

export(NodePath) var color_picker

func gui_input(ev):
	if(ev is InputEventMouseButton && ev.button_index == BUTTON_LEFT && ev.pressed):
		get_node(color_picker).selected = self
		get_node(color_picker).selected_index = get_position_in_parent()
	if(ev is InputEventMouseButton && ev.button_index == BUTTON_RIGHT && ev.pressed):
		print("right")

func reload():
	color = get_node("../../../../Viewport/GridMap").theme.get_item_mesh(get_position_in_parent()).material.albedo_color