tool
extends Button

var plugin = null
var file_dialog = null

func _ready():
	file_dialog = EditorFileDialog.new()
	file_dialog.connect("file_selected",get_node("../../../Viewport/GridMap"),'on_load')
	file_dialog.mode = EditorFileDialog.MODE_OPEN_FILE
	file_dialog.current_dir = "res://voxel_models"
	add_child(file_dialog)

func on_pressed():
	file_dialog.invalidate()
	file_dialog.popup_centered(Vector2(800,600))
