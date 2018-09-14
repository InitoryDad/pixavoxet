tool
extends Path

export var model_index = 0
export var voxel_interpolation = 1
var current_model = null

func _process(delta):
	#make current model visible
	for model in get_children():
		if(model.get_class() != "Position3D"):
			if(model.get_position_in_parent() != model_index):
				model.visible = false
			elif(!model.visible):
				model.visible = true
			if(model.get_position_in_parent() == model_index):
				current_model = model
	var length = 0
	curve.clear_points()
	curve.add_point(Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),0)
	var index = 1
	for point in get_children():
		if(point is Position3D):
			var _in = Vector3(0,0,0)
			var _out = Vector3(0,0,0)
			var children = point.get_children()
			if(children.size() >= 1):
				_in = children[0].translation
			if(children.size() >= 2):
				_out = children[1].translation
			curve.add_point(point.translation, _in, _out, index)
			index += 1
	length = curve.get_baked_length()
	if(curve.get_point_count() > 1):
		for voxel in current_model.get_children():
			var pf1 = PathFollow.new()
			var pf2 = PathFollow.new()
			pf1.loop = false
			pf1.cubic_interp = true
			pf1.rotation_mode = PathFollow.ROTATION_XYZ
			pf2.loop = false
			pf2.cubic_interp = true
			pf2.rotation_mode = PathFollow.ROTATION_XYZ
			add_child(pf1)
			add_child(pf2)
			voxel.rotation_degrees = Vector3(0,0,0)
			voxel.scale = Vector3(1,1,1)
			voxel.translation = voxel.initial_position
			var position = voxel.initial_position
			var offset = range_lerp(position.y,0,current_model.size.y,0,length)
			var offset2 = range_lerp(max(0,position.y-1),0,current_model.size.y,0,length)
			pf1.offset = offset
			pf2.offset = offset2
			pf1.transform = pf1.transform.translated(position)
			pf2.transform = pf2.transform.translated(position)
			voxel.transform = pf1.transform
			voxel.scale.y += pf1.translation.distance_to(pf2.translation)
			remove_child(pf1)
			remove_child(pf2)
			pf1.free()
			pf2.free()

func angle(a,b):
	return acos(a.dot(b))

func toEuler(axis, angle):
	var x = axis.x
	var y = axis.y
	var z = axis.z
	var s = sin(angle)
	var c = cos(angle)
	var t = 1.0-c
	if ((x*y*t + z*s) > 0.998):
		var heading = 2.0*atan2(x * sin(angle/2.0), cos(angle/2.0))
		var attitude = PI/2.0
		var bank = 0
		return Vector3(heading,attitude,bank)
	if ((x*y*t + z*s) < -0.998):
		var heading = -2.0 * atan2(x * sin(angle/2.0), cos(angle/2.0))
		var attitude = -PI/2.0
		var bank = 0
		return Vector3(heading,attitude,bank)
	var heading = atan2(y * s- x * z * t , 1.0 - (y*y+ z*z ) * t)
	var attitude = asin(x * y * t + z * s)
	var bank = atan2(x * s - y * z * t , 1.0 - (x*x + z*z) * t)
	return Vector3(heading,attitude,bank)
