tool
extends Spatial

export var model = ""
export var size = Vector3(10,10,10)
export var pivot = Vector3(0,0,0)
var voxels = {}
var voxel_children = {}

func _enter_tree():
	add_to_group("voxel_mom")