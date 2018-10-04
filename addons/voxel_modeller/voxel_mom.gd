tool
extends Spatial

export var model = ""
export var size = Vector3(10,10,10)
export var pivot = Vector3(5,0,5)
var voxels = {}
var voxel_children = {}

func _enter_tree():
	if(!is_in_group("voxel_model")):
		add_to_group("voxel_model",true)

#func _process(delta):
#	var index = 0
#	while(get_child_count() < voxels.keys().size() * get_parent().voxel_interpolation):
#		get_child(index)