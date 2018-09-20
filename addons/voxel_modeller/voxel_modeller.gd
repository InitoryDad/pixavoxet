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
	voxel_modeller.plugin = self
	get_editor_interface().get_editor_viewport().add_child(voxel_modeller)
	voxel_modeller.hide()
	voxel_modeller.get_node("ViewportContainer").undoredo = get_undo_redo()
	#get_editor_interface().get_resource_filesystem().connect("filesystem_changed",self,"hello")

func undoredo_print(string):
	return

func _exit_tree():
	get_editor_interface().get_editor_viewport().remove_child(voxel_modeller)
	if(voxel_modeller):
		voxel_modeller.free()

func _process(delta):
	var p = voxel_modeller.get_parent()
	voxel_modeller.get_node("ViewportContainer").rect_size = p.rect_size

func rescan(file_path):
	print("scanning filesystem")
	get_editor_interface().get_resource_filesystem().scan_sources()
	get_editor_interface().get_resource_filesystem().update_file(file_path)
