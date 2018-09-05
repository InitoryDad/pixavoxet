tool
extends EditorPlugin
var VOXEL_MODELLER = preload("voxel_modeller.tscn")
var toolmode = "box"
var voxel_modeller = null

func get_plugin_name():
	return "Voxel Modeller"
#
func has_main_screen():
	return true
#
func make_visible(visible):
	if(voxel_modeller && visible):
		voxel_modeller.show()
	elif(voxel_modeller):
		voxel_modeller.hide()

func _enter_tree():
	voxel_modeller = VOXEL_MODELLER.instance()
	get_editor_interface().get_editor_viewport().add_child(voxel_modeller)
	voxel_modeller.hide()
	voxel_modeller.get_node("ViewportContainer").undoredo = get_undo_redo()

func undoredo_print(string):
	print(string)

func _exit_tree():
	get_editor_interface().get_editor_viewport().remove_child(voxel_modeller)
	if(voxel_modeller):
		voxel_modeller.free()

func _process(delta):
	var p = voxel_modeller.get_parent()
	voxel_modeller.get_node("ViewportContainer").rect_size = p.rect_size
