tool
extends MeshInstance

var mesh_library = preload("res://addons/voxel_modeller/noxel.meshlib")
export var color_index = 0
export var color = Color(0,0,0,1)

func _enter_tree():
	add_to_group("voxel")

func get_color():
	return color