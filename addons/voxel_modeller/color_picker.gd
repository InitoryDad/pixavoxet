tool
extends ColorPicker

var selected = null setget set_selected
var selected_index = 0
var first = null
var material_lookup = {}


func _ready():
	for node in get_parent().get_node("colors").get_children():
		if(!selected):
			selected = node
		var mat = SpatialMaterial.new()
		mat.albedo_color = node.color
		material_lookup[node] = mat

func get_selected_material():
	return material_lookup[selected]

func set_selected(swatch):
	color = swatch.color
	selected = swatch

func color_changed(color):
	get_parent().get_parent().get_parent().get_node("Viewport").render_target_update_mode = Viewport.UPDATE_ONCE
	if(selected):
		selected.color = color
		material_lookup[selected].albedo_color = color
