tool
extends Path

export var model_index = 0
export var voxel_interpolation = 1
export var use_curve_scaling = false
var THREAD_COUNT = 10
var threads = []
var voxel_index = 0
var current_model = null
var points = []
var pf1
var pf2
var s

signal transform_pass_complete

func _process(delta):
	if(pf1 == null):
		pf1 = PathFollow.new()
		pf2 = PathFollow.new()
		s = Spatial.new()
		pf1.loop = false
		pf2.loop = false
		add_child(pf1)
		add_child(pf2)
		pf1.add_child(s)
	curve.clear_points()
	points = []
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
			if(index == 0):
				point.translation = Vector3()
			var _in = Vector3(0,0,0)
			var _out = Vector3(0,0,0)
			var children = point.get_children()
			if(children.size() >= 1):
				_in = children[0].translation
			if(children.size() >= 2):
				_out = children[1].translation
			if(point.translation != Vector3() || index == 0):
				curve.add_point(point.translation, _in, _out, index)
				length_dictionary[curve.get_point_count()-1] = curve.get_baked_length()
				index += 1
	if(curve.get_point_count() > 1):
		if(use_curve_scaling):
			if(threads.empty()):
				for i in THREAD_COUNT:
					threads.append(Thread.new())
			if(voxel_index > current_model.get_child_count()-1):
				voxel_index = 0
				emit_signal("transform_pass_complete")
			var active = 0
			while(active < THREAD_COUNT && voxel_index < current_model.get_child_count()):
				if(!threads[active].is_active()):
					threads[active].start(self, "calculate_transform", [current_model.get_child(voxel_index),length_dictionary])
					threads[active].call_deferred("wait_to_finish")
					voxel_index += 1
				else:
					threads[active].wait_to_finish()
				active += 1
		else:
			for voxel in current_model.get_children():
				calculate_transform([voxel,length_dictionary])
	else:
		if(current_model && curve.get_point_count() <= 1):
			for voxel in current_model.get_children():
				if(voxel.is_in_group("voxel")):
					voxel.rotation_degrees = Vector3(0,0,0)
					voxel.scale = Vector3(1,1,1)
					voxel.translation = voxel.initial_position

func calculate_transform(data):
	var voxel = data[0]
	var length_dictionary = data[1]
	if(voxel.is_in_group("voxel")):
		voxel.rotation_degrees = Vector3(0,0,0)
		voxel.scale = Vector3(1,1,1)
		voxel.translation = voxel.initial_position
		var length = curve.get_baked_length()
		var position = voxel.initial_position
		s.translation = Vector3(position.z+.5+(position.y*.01),-position.x-.5+(position.y*.01),0)
		var offset = range_lerp(position.y+current_model.pivot.y,current_model.pivot.y-1,current_model.size.y,0,length)
		var offset2 = range_lerp(position.y+current_model.pivot.y+.5,current_model.pivot.y-1,current_model.size.y,0,length)
		var offset3 = range_lerp(position.y+current_model.pivot.y-1,current_model.pivot.y-1,current_model.size.y,0,length)
		pf1.offset = offset
		pf2.offset = offset2
		if(pf1.transform.origin != pf2.translation):
			pf1.transform = pf1.transform.looking_at(pf2.translation,Vector3(0,1,0))
		pf2.offset = offset3
		var distance = pf1.translation.distance_to(pf2.translation)
		voxel.global_transform = s.global_transform
		if(use_curve_scaling):
			var idx = get_look_at_point_idx(offset,length_dictionary)
			var p1 = points[idx]
			var p2 = points[idx-1]
			var point_distance = p2.translation.distance_to(p1.translation)
			var self_distance = pf1.translation.distance_to(p2.translation)
			var lerp_amount = range_lerp(self_distance, 0, point_distance, 0, 1)
			var scale_factor = p2.scale.linear_interpolate(p1.scale,lerp_amount)
			if(is_nan(scale_factor.x)):
				scale_factor = Vector3(1,1,1)
			if(voxel.scale != Vector3(scale_factor.x,scale_factor.y,distance + scale_factor.z)):
				voxel.scale = Vector3(scale_factor.x,scale_factor.y,distance + scale_factor.z)
		else:
			voxel.scale.z = distance

func get_look_at_point_idx(offset,dic):
	for key in dic.keys():
		var length = dic[key]
		if(offset < length):
			return key
	return 0

