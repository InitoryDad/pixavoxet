tool
extends Spatial

export var energy = 1.0
export var banding_amount = .25
export var shadow_clamp = .5
export var shadow_cast_amount = .5
export var visible_voxels_only = true
export var reset = true
var last_translation = Vector3(-9999,-9999,-9999)
var voxels = []
var voxel_index = 0

func _process(delta):
	if(visible):
		if(visible_voxels_only):
			voxels = $"../FramePreview".get_visible_voxels()
		else:
			voxels = get_tree().get_nodes_in_group("voxel_visible")
		light_pass()
	else:
		if(visible_voxels_only):
			voxels = $"../FramePreview".get_visible_voxels()
		else:
			voxels = get_tree().get_nodes_in_group("voxel_visible")
		reset_pass()

func reset_pass():
	for voxel in voxels:
		voxel.material_override.albedo_color = voxel.color

func light_pass():
	for voxel in voxels:
		calculate_color(voxel)

func calculate_color(voxel):
	var color = voxel.color
	voxel.material_override.albedo_color = color
	for light in get_children():
#
		color = voxel.material_override.albedo_color
#		if(reset):
#			color = voxel.color
		var state = get_world().direct_space_state
		var from = light.global_transform.origin
		var to = voxel.global_transform.origin
		var direction = from - to
		var hit = state.intersect_ray(from,to + (direction.normalized() * 5),[voxel.get_child(0)],4)
		if(!hit.empty()): #cast_shadow
			var darkened = color.darkened(shadow_cast_amount)
			voxel.material_override.albedo_color = darkened
		else:
			var attenuation = light.global_transform.origin.distance_to(voxel.global_transform.origin)
			var e = max(0,min(stepify(exp(attenuation/100.0) * 1.0-energy,banding_amount), shadow_clamp))
			var darkened = color.darkened(e)
			voxel.material_override.albedo_color = darkened
