tool
extends MeshInstance

export var color_index = 0
export var color = Color(0,0,0,1)
var initial_position = Vector3(0,0,0)

func _enter_tree():
	if(!is_in_group("voxel")):
		add_to_group("voxel",true)

func _ready():
	if(!mesh):
		var cube = CubeMesh.new()
		cube.size = Vector3(1,1,1)
		mesh = cube
	material_override.albedo_color = color
	initial_position = translation

func get_color():
	return color