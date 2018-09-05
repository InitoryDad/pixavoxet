tool
extends GridMap

var VOXEL_SCENE = preload("voxel.tscn")
var VOXEL_SCRIPT = preload("voxel.gd")
var VOXEL_MOM_SCRIPT = preload("voxel_mom.gd")
var cull_hidden = true

func on_load(file_path):
	clear()
	var model = load(file_path).instance()
	for voxel in model.get_children():
		var p = voxel.translation
		var i = voxel.color_index
		var c = voxel.color
		theme.get_item_mesh(i).material.albedo_color = c
		set_cell_item(p.x,p.y,p.z,i)
	get_parent().render_target_update_mode = Viewport.UPDATE_ONCE
	set_octant_size(16)
	make_baked_meshes()
	var meshes = get_bake_meshes()
	for child in $Collision.get_children():
		$Collision.remove_child(child)
		child.free()
	var transform = null
	for mesh in meshes:
		if(typeof(mesh) != TYPE_TRANSFORM):
			var col = CollisionShape.new()
			col.shape = mesh.create_trimesh_shape()
			$Collision.add_child(col)
	set_octant_size(8)
	for swatch in get_node("../../LeftSideBar/VBoxContainer/colors").get_children():
		swatch.reload()

func on_save():
	var scene = PackedScene.new()
	var voxel_mom = Spatial.new()
	voxel_mom.set_script(VOXEL_MOM_SCRIPT)
	var cube = CubeMesh.new()
	cube.size = Vector3(1,1,1)
	var cells = get_used_cells()
	for p in cells:
		var top = get_cell_item(p.x,p.y+1,p.z)
		var bottom = get_cell_item(p.x,p.y-1,p.z)
		var left = get_cell_item(p.x-1,p.y,p.z)
		var right = get_cell_item(p.x+1,p.y,p.z)
		var front = get_cell_item(p.x,p.y,p.z-1)
		var back = get_cell_item(p.x,p.y,p.z+1)
		var a = [top,bottom,left,right,front,back]
		a.sort()
		if(!cull_hidden || a[0] == -1):
			var mi = VOXEL_SCENE.instance()
			var i = get_cell_item(p.x,p.y,p.z)
			var m = theme.get_item_mesh(i).material.duplicate()
			mi.color_index = i
			mi.color = m.albedo_color
			m.flags_unshaded = true
			m.flags_albedo_tex_force_srgb = true
			mi.material_override = m
			mi.translation = p
			voxel_mom.add_child(mi)
			mi.owner = voxel_mom
	var result = scene.pack(voxel_mom)
	if result == OK:
		ResourceSaver.save("res://voxel_models/model.scn", scene)