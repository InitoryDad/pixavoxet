tool
extends ColorPicker

var selected = null setget set_selected
var selected_index = 0
var first = null
var material_lookup = {}


func _ready():
	refresh()


func refresh():
	for node in get_parent().get_node("colors").get_children():
		if(!selected):
			selected = node
		var mat = get_node("../../../Viewport/GridMap").theme.get_item_mesh(node.get_position_in_parent()).material
		node.color = mat.albedo_color
		material_lookup[node.get_position_in_parent()] = mat

func get_material(index):
	return material_lookup[index]

func get_selected_material():
	return material_lookup[selected_index]

func set_selected(swatch):
	color = swatch.color
	selected = swatch

func color_changed(color):
	get_parent().get_parent().get_parent().get_node("Viewport").render_target_update_mode = Viewport.UPDATE_ONCE
	if(selected):
		selected.color = color
		material_lookup[selected_index].albedo_color = color
