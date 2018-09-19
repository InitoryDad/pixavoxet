tool
extends Spatial

export var energy = 1.0
export var banding_amount = .25
export var shadow_clamp = .5
var THREAD_COUNT = 200
var threads = []
var last_translation = Vector3(-9999,-9999,-9999)
var voxels = []
var voxel_index = 0
var use_threads = true
signal light_pass_complete

func _process(delta):
	if(threads.empty()):
		for i in THREAD_COUNT:
			threads.append(Thread.new())
	voxels = []
	for voxel_mom in get_tree().get_nodes_in_group("voxel_model"):
		if(voxel_mom.visible):
			voxels = voxels + voxel_mom.get_children()
	light_pass()

func light_pass():
	if(voxel_index >= voxels.size()-1):
		voxel_index = 0
		emit_signal("light_pass_complete")
	if(use_threads):
		var active = 0
		while(active < THREAD_COUNT && voxel_index < voxels.size()):
			if(!threads[active].is_active()):
				threads[active].start(self, "calculate_color", voxels[voxel_index])
				threads[active].call_deferred("wait_to_finish")
				voxel_index += 1
			active += 1
	else:
		calculate_color(voxels[voxel_index])
		voxel_index += 1

func calculate_color(voxel):
	var color = voxel.color
	var state = get_world().direct_space_state
	if(voxel.is_visible_in_tree()):
		var from = global_transform.origin
		var to = voxel.global_transform.origin
		var direction = from - to
		var hit = state.intersect_ray(from,to + (direction.normalized() * 5),[voxel.get_child(0)])
		if(!hit.empty()): #cast_shadow
			var darkened = color.darkened(shadow_clamp)
			voxel.material_override.albedo_color = darkened
		else:
			var attenuation = translation.distance_to(voxel.global_transform.origin)
			var e = min(stepify(exp(attenuation/100.0) * (1.0-energy),banding_amount), shadow_clamp)
			var darkened = color.darkened(e)
			voxel.material_override.albedo_color = darkened
