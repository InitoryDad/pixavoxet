tool
extends Spatial

export var energy = 1.0
export var banding_amount = .25
export var shadow_clamp = .5
var THREAD_COUNT = 100
var threads = []
var last_translation = Vector3(-9999,-9999,-9999)
var voxels = []
var voxel_index = 0
var use_threads = true
var world_state

func _enter_tree():
	for i in THREAD_COUNT:
		threads.append(Thread.new())
	#PhysicsServer.set_active(true)

func _process(delta):
	voxels = get_tree().get_nodes_in_group("voxel")
	light_pass()

func _physics_process(delta):
	world_state = get_world().direct_space_state

func light_pass():
	if(voxel_index >= voxels.size()-1):
		voxel_index = 0
#		emit_signal("light_pass_complete")
	if(use_threads):
		var active = 0
		while(active < THREAD_COUNT && voxel_index < voxels.size()):
			threads[active].start(self, "calculate_color", [voxels[voxel_index], voxels[voxel_index].get_color(), world_state])
			threads[active].wait_to_finish()
			active += 1
			voxel_index += 1
	else:
		calculate_color([voxels[voxel_index],voxels[voxel_index].get_color(),world_state])
		voxel_index += 1

func calculate_color(data):
	var voxel = data[0]
	var color = data[1]
	var state = data[2]
	if(voxel.is_visible_in_tree()):
		var from = global_transform.origin
		var to = voxel.global_transform.origin
		var direction = from - to
		var hit = state.intersect_ray(from,to + direction.normalized(),[voxel.get_child(0)])
		if(!hit.empty()): #cast_shadow
			var darkened = color.darkened(shadow_clamp)
			voxel.material_override.albedo_color = darkened
		else:
			var attenuation = translation.distance_to(voxel.global_transform.origin)
			var e = min(stepify(exp(attenuation/10) * max(.01,1-energy),banding_amount), shadow_clamp)
			var darkened = color.darkened(e)
			voxel.material_override.albedo_color = darkened
