tool
extends Spatial

export var indexed_colors = false
export(NodePath) var light = null
export var light_color = Color(1,1,.9,1)
export var light_pass = true
export var light_strength = .4
export var light_bands = 8.0
export var light_reach = 50

export var shadow_color = Color(0,0,0,1)
export var cast_shadows = true
export var shadow_precision = 4.0
export var shadow_strength = .22

export var outline_color = Color(0,0,0,1)
export var outline_pass = true
export var outline_reset_colors = false
export var outline_distance = 3.0
export var outline_strength = 0.5
export var depth_outline = true

export var color_fix = true

export var cull_back = true

const VOXEL_INSTANCE_CLASS = preload("res://Voxel Importer/magicavoxel_instance.gd")


var wait = 0

func _process(delta):
	update_transforms()
	if(color_fix):
		color_fix()
	if(light_pass && indexed_colors):
		shade_pass_indexed(light)
	if(light_pass && !indexed_colors):
		shade_pass(light)
	if(outline_pass):
		outline_pass()

func color_fix():
	for voxel_node in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
		if(voxel_node.vox_file_path != "" && voxel_node.is_visible_in_tree()):
			for i in voxel_node.multi_mesh_instance.multimesh.instance_count:
				var c = voxel_node.multi_mesh_color_lookup[i]
				voxel_node.multi_mesh_instance.multimesh.set_instance_color(i,c)

func update_transforms():
	for voxel_node in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
		if(voxel_node.vox_file_path != ""):
			if(voxel_node.is_visible_in_tree()):
				voxel_node.multi_mesh_instance.visible = true
				for index in range(0,voxel_node.multi_mesh_instance.multimesh.instance_count):
					var model = voxel_node.magica_voxel_file.models[voxel_node.model_index]
					var size = model.size
					var offset = Vector3(size.y/2,0,size.x/2) + voxel_node.offset_pivot
					var position = model.voxels.keys()[index]
					var aa = voxel_node.transform.origin
					voxel_node.multi_mesh_instance.multimesh.set_instance_transform(index, Transform(Basis(), position - offset))
					var t = voxel_node.multi_mesh_instance.multimesh.get_instance_transform(index)
					var t2 = voxel_node.global_transform
					var a = t2.basis.orthonormalized().get_euler()
					var b = t2.basis.orthonormalized().transposed().get_euler()
					t2 = t2.rotated(Vector3(0,0,1),b.z)
					t2 = t2.rotated(Vector3(1,0,0),b.x)
					t2 = t2.rotated(Vector3(0,1,0),b.y)
					t = t.translated(t2.origin)
					t = t.rotated(Vector3(0,0,1),a.z)
					t = t.rotated(Vector3(1,0,0),a.x)
					t = t.rotated(Vector3(0,1,0),a.y)
					voxel_node.multi_mesh_instance.multimesh.set_instance_transform(index,t)
			else:
				voxel_node.multi_mesh_instance.visible = false

func shade_pass_indexed(_light):
	for voxel_node in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
		if(voxel_node.vox_file_path != "" && voxel_node.is_visible_in_tree()):
			var positions_index = {}
			var index_positions = {}
			for i in voxel_node.multi_mesh_instance.multimesh.instance_count:
				var t = voxel_node.multi_mesh_instance.multimesh.get_instance_transform(i)
				var v = Vector3(floor(t.origin.x)-5,floor(t.origin.y),floor(t.origin.z))
				var add = true
				if(cull_back):
					for vn in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
						if(vn.is_visible_in_tree() && vn.multi_mesh_instance.multimesh):
							var mmaabb = vn.multi_mesh_instance.multimesh.get_aabb()
							if(mmaabb.intersects_segment(v,v - Vector3(100,0,0))):
								add = false
						if(!add):
							break
				if(add):
					positions_index[t.origin] = i
					index_positions[i] = t.origin
			var o = get_node(_light).global_transform.origin
			for position in positions_index.keys():
				var i = positions_index[position]
				var color = null
				var is_casted_shadow = false
				if(cast_shadows):
					color = null
					var light_vector = get_node(_light).global_transform.origin
					for vn in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
						if(vn.is_visible_in_tree() && vn.multi_mesh_instance.multimesh):
							var mmaabb = vn.multi_mesh_instance.multimesh.get_aabb()
							var direction = position - light_vector
							if(mmaabb.intersects_segment(position - direction.normalized()*4,light_vector)):
								#Is Cast Shadow
								is_casted_shadow = true
								var n = floor(range_lerp(position.distance_to(light_vector),0,light_reach,0,3))
								var c = voxel_node.multi_mesh_color_index[i]
								color = voxel_node.magica_voxel_file.palette[min(c+2,255)]
								voxel_node.multi_mesh_instance.multimesh.set_instance_color(i,color)
								break
				if(!is_casted_shadow):
#					color = voxel_node.multi_mesh_color_lookup[i]
					var z = 0
					var dis = position.distance_to(get_node(_light).global_transform.origin)
					if(dis >= light_reach):
						var n = floor(range_lerp(dis,0,light_reach,0,3))
						var c = voxel_node.multi_mesh_color_index[i]
						color = voxel_node.magica_voxel_file.palette[min(c+1,255)]
					elif(dis < light_reach):
						var n = floor(range_lerp(dis,0,light_reach,0,3))
						var c = voxel_node.multi_mesh_color_index[i]
						color = voxel_node.magica_voxel_file.palette[max(c,0)]
					voxel_node.multi_mesh_instance.multimesh.set_instance_color(i,color)

func shade_pass(_light):
	for voxel_node in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
		if(voxel_node.vox_file_path != "" && voxel_node.is_visible_in_tree()):
			var positions_index = {}
			var index_positions = {}
			for i in voxel_node.multi_mesh_instance.multimesh.instance_count:
				var t = voxel_node.multi_mesh_instance.multimesh.get_instance_transform(i)
				var v = Vector3(floor(t.origin.x)-5,floor(t.origin.y),floor(t.origin.z))
				var add = true
				if(cull_back):
					for vn in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
						if(vn.is_visible_in_tree() && vn.multi_mesh_instance.multimesh):
							var mmaabb = vn.multi_mesh_instance.multimesh.get_aabb()
							if(mmaabb.intersects_segment(v,v - Vector3(100,0,0))):
								add = false
						if(!add):
							break
				if(add):
					positions_index[t.origin] = i
					index_positions[i] = t.origin
			var o = get_node(_light).global_transform.origin
			for position in positions_index.keys():
				var i = positions_index[position]
				var color = null
				var is_casted_shadow = false
				if(cast_shadows):
					var light_vector = get_node(_light).global_transform.origin
					for vn in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
						if(vn.is_visible_in_tree() && vn.multi_mesh_instance.multimesh):
							var mmaabb = vn.multi_mesh_instance.multimesh.get_aabb()
							var direction = position - light_vector
							if(mmaabb.intersects_segment(position - direction.normalized()*4,light_vector)):
								#Is Cast Shadow
								is_casted_shadow = true
								color = voxel_node.multi_mesh_color_lookup[i]
								var dis = position.normalized().distance_to(get_node(_light).transform.origin.normalized())*shadow_strength
								color = color.darkened(dis)
								color = color.linear_interpolate(shadow_color, round(dis*light_bands)/light_bands)
								voxel_node.multi_mesh_instance.multimesh.set_instance_color(i,color)
								break
				if(!is_casted_shadow):
					color = voxel_node.multi_mesh_color_lookup[i]
					var z = 0
					var dis = position.distance_to(get_node(_light).global_transform.origin)
					if(dis >= light_reach):
						dis = range_lerp(dis-light_reach,0,dis,0,1)
						z = dis
						color = color.darkened((round(z*light_bands)/light_bands)*light_strength)
						z = (1-dis)*shadow_strength
						var lc = shadow_color
						lc.a = round(z*light_bands)/light_bands
						color = color.blend(lc)
					elif(dis < light_reach):
						dis = range_lerp(dis,0,light_reach,0,1)
						z = 1-dis
						color = color.lightened((round(z*light_bands)/light_bands)*light_strength)
						z = (1-dis)*light_strength
						var lc = light_color
						lc.a = round(z*light_bands)/light_bands
						color = color.blend(lc)
					voxel_node.multi_mesh_instance.multimesh.set_instance_color(i,color)

func get_all_children_of_type(node, type):
	var children = []
	for child in node.get_children():
		if child.get_child_count() > 0:
			var children_temp = get_all_children_of_type(child,type)
			for c in children_temp:
				if(c is type):
					children.append(c)
			children.append(child)
		else:
			if(child is type):
				children.append(child)
	return children

func outline_pass():
	for voxel_node in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
		if(voxel_node.vox_file_path != "" && voxel_node.is_visible_in_tree()):
			var flattened_index = {}
			for i in voxel_node.multi_mesh_instance.multimesh.instance_count:
				var t = voxel_node.multi_mesh_instance.multimesh.get_instance_transform(i)
				var v = Vector3(t.origin.x-1,t.origin.y,t.origin.z)
				var add = true
				if(cull_back):
					for vn in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
						if(vn.is_visible_in_tree() && vn.multi_mesh_instance.multimesh && vn != voxel_node):
							var mmaabb = vn.multi_mesh_instance.multimesh.get_aabb()
							if(mmaabb.intersects_segment(v,v - Vector3(100,0,0))):
								add = false
						if(!add):
							break
				if(add):
					var p = t.origin.round()
					var zy = Vector2(p.z,p.y)
					if(!flattened_index.has(zy)):
						flattened_index[zy] = [t.origin,i]
					elif(flattened_index.has(zy)):
						var x = flattened_index[zy][0].x
						if(x > t.origin.x):
							flattened_index[zy] = [t.origin,i]
			for zy in flattened_index.keys():
				var outline = null
				var p = flattened_index[zy][0] - Vector3(1,0,0)
				var n = 1
				var s = .1
				var u = p - Vector3(outline_distance,n,0)
				var d = p - Vector3(outline_distance,-n,0)
				var l = p - Vector3(outline_distance,0,-n)
				var r = p - Vector3(outline_distance,0,n)
				for vn in get_all_children_of_type(self, VOXEL_INSTANCE_CLASS):
					if(vn.is_visible_in_tree() && vn.multi_mesh_instance.multimesh && vn != voxel_node):
						var mmaabb = vn.multi_mesh_instance.multimesh.get_aabb()
						if(mmaabb.intersects_segment(u, u -Vector3(100,0,0))):
							outline = mmaabb.position.distance_to(p)
						if(mmaabb.intersects_segment(d, d -Vector3(100,0,0))):
							outline = mmaabb.position.distance_to(p)
						if(mmaabb.intersects_segment(l, l -Vector3(100,0,0))):
							outline = mmaabb.position.distance_to(p)
						if(mmaabb.intersects_segment(r, r -Vector3(100,0,0))):
							outline = mmaabb.position.distance_to(p)
					if(outline):
						break
				var index = flattened_index[zy][1]
				var color = voxel_node.multi_mesh_instance.multimesh.get_instance_color(index)
				if(outline_reset_colors):
					color = voxel_node.multi_mesh_color_lookup[index]
				if(outline):
					if(!depth_outline):
						outline = 1
					color = color.darkened(outline_strength)
					color = color.linear_interpolate(outline_color,outline_strength * outline)
					#var c = voxel_node.multi_mesh_color_index[index]
					#color = voxel_node.magica_voxel_file.palette[max(c+2,0)]
					voxel_node.multi_mesh_instance.multimesh.set_instance_color(index, color)
