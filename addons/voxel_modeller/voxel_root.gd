tool
extends Path

export var model_index = 0
export var voxel_interpolation = 1
var current_model = null
var points = []
var scales = []


func _process(delta):
	#curve.clear_points()
	var curve2 = Curve3D.new()
	points = []
	var scales2 = []
	var paths = []
	var length_dictionary = {}
	var index = 0
	for model in get_children():
		if(model.is_in_group("voxel_model")):
			if(model.get_position_in_parent() != model_index):
				model.visible = false
			elif(!model.visible):
				model.visible = true
			if(model.get_position_in_parent() == model_index):
				current_model = model
		elif(model.get_class() == "Position3D"):
			var point = model
			points.append(point)
			scales2.append(point.scale)
			if(index == 0):
				point.translation = Vector3()
			var _in = Vector3(0,0,0)
			var _out = Vector3(0,0,0)
			var children = point.get_children()
			if(children.size() >= 1):
				_in = children[0].translation
			if(children.size() >= 2):
				_out = children[1].translation
			curve2.add_point(point.translation, _in, _out, index)
			length_dictionary[curve2.get_point_count()-1] = curve2.get_baked_length()
			index += 1
	var update = false
	if(curve2.get_point_count() != curve.get_point_count() || scales.size() != scales2.size()):
		update = true
		curve = curve2
		scales = scales2
	else:
		for idx in curve2.get_point_count():
			if(curve.get_point_position(idx) != curve2.get_point_position(idx)):
				update = true
				curve = curve2
		for idx in scales2.size():
			if(scales[idx] != scales2[idx]):
				update = true
				scales = scales2
				curve = curve2
	if(curve.get_point_count() > 1 && update):
		var length = curve.get_baked_length()
		for voxel in current_model.get_children():
			if(voxel.is_in_group("voxel")):
				voxel.scale = Vector3(1,1,1)
				voxel.translation = voxel.initial_position
				var position = voxel.initial_position
				var pf1 = PathFollow.new()
				pf1.loop = false
				var pf2 = PathFollow.new()
				pf2.loop = false
				add_child(pf1)
				add_child(pf2)
				var s = Spatial.new()
				pf1.add_child(s)
				s.translation = Vector3(position.z+.5,-position.x-.5,0)
				var offset = range_lerp(position.y+current_model.pivot.y,current_model.pivot.y,current_model.size.y,0,length)
				var offset2 = range_lerp(position.y+current_model.pivot.y+1,current_model.pivot.y,current_model.size.y,0,length)
				var idx = get_look_at_point_idx(offset,length_dictionary)
				var p1 = points[idx]
				var p2 = points[idx-1]
				pf1.offset = offset
				pf2.offset = offset2
				var distance = pf1.translation.distance_to(pf2.translation)
				if(pf1.translation != pf2.translation):
					pf1.transform = pf1.transform.looking_at(pf2.translation,Vector3(0,1,0))
				voxel.global_transform = s.global_transform
				var point_distance = p2.translation.distance_to(p1.translation)
				var self_distance = pf1.translation.distance_to(p2.translation)
				var lerp_amount = range_lerp(self_distance, 0, point_distance, 0, 1)
				var scale_factor = p2.scale.linear_interpolate(p1.scale,lerp_amount)
				if(is_nan(scale_factor.x)):
					scale_factor = Vector3(1,1,1)
				voxel.scale = Vector3(scale_factor.x,scale_factor.y,distance + scale_factor.z)
#				voxel.scale.z = max(1,(distance + scale_factor.z))
#				voxel.scale.x = max(1,(scale_factor.x))
#				voxel.scale.y = max(1,(scale_factor.y))
				s.free()
				pf1.free()
				pf2.free()
	else:
		if(current_model && points.size() <= 1):
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

