tool
extends Path

export var model_index = 0
export var voxel_interpolation = 1
var current_model = null


func _process(delta):
	#make current model visible
	var points = []
	var paths = []
	var length_dictionary = {}
	for model in get_children():
		if(model.is_in_group("voxel_model")):
			if(model.get_position_in_parent() != model_index):
				model.visible = false
			elif(!model.visible):
				model.visible = true
			if(model.get_position_in_parent() == model_index):
				current_model = model
		elif(model.get_class() == "Position3D"):
			points.append(model)
	curve.clear_points()
	curve.add_point(Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),0)
	var index = 1
	for point in points:
		length_dictionary[curve.get_point_count()-1] = curve.get_baked_length()
		var _in = Vector3(0,0,0)
		var _out = Vector3(0,0,0)
		var children = point.get_children()
		if(children.size() >= 1):
			_in = children[0].translation
		if(children.size() >= 2):
			_out = children[1].translatio
		curve.add_point(point.translation, _in, _out, index)
		index += 1
	length_dictionary[curve.get_point_count()-1] = curve.get_baked_length()
#	print(length_dictionary)
	if(curve.get_point_count() > 1):
		var length = curve.get_baked_length()
		var rot = rotation
		var rot_dict = {}
		for voxel in current_model.get_children():
			if(voxel.is_in_group("voxel")):
				voxel.scale = Vector3(1,1,1)
				voxel.translation = voxel.initial_position
				var position = voxel.initial_position
				var pf1 = PathFollow.new()
				pf1.loop = true
				pf1.cubic_interp = true
				pf1.rotation_mode = PathFollow.ROTATION_NONE
				add_child(pf1)
				var s = Spatial.new()
				pf1.add_child(s)
				s.translation = Vector3(position.x+.5,0,position.z+.5)
				var offset = range_lerp(position.y+current_model.pivot.y,0,current_model.size.y,0,length)
				var idx = get_look_at_point_idx(offset,length_dictionary)
				pf1.translation = curve.get_point_position(idx-1)
				pf1.transform = pf1.transform.looking_at(curve.get_point_position(idx),Vector3(0,1,0))
				pf1.rotation_degrees += Vector3(90,0,0)
				pf1.offset = length+offset
				voxel.global_transform = s.global_transform
				remove_child(pf1)
				pf1.free()
	else:
		if(current_model):
			for voxel in current_model.get_children():
				if(voxel.is_in_group("voxel")):
					voxel.rotation_degrees = Vector3(0,0,0)
					voxel.scale = Vector3(1,1,1)
					voxel.translation = voxel.initial_position

func get_look_at_point_idx(offset,dic):
	for key in dic.keys():
		var length = dic[key]
		if(offset < length):
			return key
	return 0

