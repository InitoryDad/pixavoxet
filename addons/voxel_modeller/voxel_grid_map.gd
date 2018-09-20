tool
extends GridMap

var VOXEL_MODEL_SCENE = preload("voxel_model.tscn")
var VOXEL_SCENE = preload("voxel.tscn")
var VOXEL_SCRIPT = preload("voxel.gd")
var VOXEL_ROOT_SCRIPT = preload("voxel_root.gd")
var VOXEL_MOM_SCRIPT = preload("voxel_mom.gd")
var cull_hidden = true
var model_index = 0
var models = []

var threads = []


func _enter_tree():
	var meshlib = MeshLibrary.new()
	for i in range(100):
		var cube = CubeMesh.new()
		cube.size = Vector3(1,1,1)
		var mat = SpatialMaterial.new()
		cube.material = mat
		meshlib.create_item(i)
		meshlib.set_item_mesh(i,cube)
	theme = meshlib
	create_model()

func create_model():
	models.append(VOXEL_MODEL_SCENE.instance())

func get_current_model():
	return models[model_index]

func refresh_materials():
	var material = SpatialMaterial.new()
	material.flags_albedo_tex_force_srgb = true
	material.albedo_color = Color(.5,.5,.5,1)
	for index in theme.get_item_list():
		theme.get_item_mesh(index).material = material.duplicate()

func add_model():
	models.insert(model_index+1, VOXEL_MODEL_SCENE.instance())
	model_index += 1
	show_current_model()

func delete_model():
	var model = models[model_index]
	models.remove(model_index)
	model.free()
	model_index = min(models.size()-1,model_index)
	show_current_model()

func set_model_index(index):
	models[model_index].size.x = get_node("../../TopBar/VBoxContainer/size/x").value
	models[model_index].size.y = get_node("../../TopBar/VBoxContainer/size/y").value
	models[model_index].size.z = get_node("../../TopBar/VBoxContainer/size/z").value
	models[model_index].pivot.x = get_node("../../TopBar/VBoxContainer/pivot/x").value
	models[model_index].pivot.y = get_node("../../TopBar/VBoxContainer/pivot/y").value
	models[model_index].pivot.z = get_node("../../TopBar/VBoxContainer/pivot/z").value
	model_index = index
	show_current_model()

func show_current_model():
	clear()
	var model = models[model_index]
	set_size_pivot(model)
	for p in model.voxels.keys():
		var i = model.voxels[p]
		set_cell_item(p.x,p.y,p.z,i)
	get_parent().render_target_update_mode = Viewport.UPDATE_ONCE
	set_octant_size(16)
	make_baked_meshes()
	var meshes = get_bake_meshes()
	for child in $Collision.get_children():
		$Collision.remove_child(child)
		child.free()
	for mesh in meshes:
		if(typeof(mesh) != TYPE_TRANSFORM):
			var col = CollisionShape.new()
			col.shape = mesh.create_trimesh_shape()
			$Collision.add_child(col)
	set_octant_size(8)
	for swatch in get_node("../../LeftSideBar/VBoxContainer/colors").get_children():
		swatch.reload()
	get_node("Matrix").reload()

func set_size_pivot(model):
	get_node("../../TopBar/VBoxContainer/size/x").value = model.size.x
	get_node("../../TopBar/VBoxContainer/size/y").value = model.size.y
	get_node("../../TopBar/VBoxContainer/size/z").value = model.size.z
	get_node("../../TopBar/VBoxContainer/pivot/x").value = model.pivot.x
	get_node("../../TopBar/VBoxContainer/pivot/y").value = model.pivot.y
	get_node("../../TopBar/VBoxContainer/pivot/z").value = model.pivot.z
	get_node("Matrix").reload()


func on_load(file_path):
	models = []
	model_index = 0
	clear()
	refresh_materials()
	get_node("../../LeftSideBar/VBoxContainer/ColorPicker").refresh()
	get_node("../../TopBar/VBoxContainer/name/TextEdit").text = file_path.get_file().get_basename()
	var scene = load(file_path).instance()
	for model in scene.get_children():
		models.append(model)
		for voxel in model.get_children():
			var p = voxel.translation + model.pivot
			var i = voxel.color_index
			var c = voxel.color
			get_node("../../LeftSideBar/VBoxContainer/ColorPicker").get_material(i).albedo_color = c
			theme.get_item_mesh(i).material = get_node("../../LeftSideBar/VBoxContainer/ColorPicker").get_material(i)
			model.voxels[p] = i
	show_current_model()

func on_save():
	models[model_index].size.x = get_node("../../TopBar/VBoxContainer/size/x").value
	models[model_index].size.y = get_node("../../TopBar/VBoxContainer/size/y").value
	models[model_index].size.z = get_node("../../TopBar/VBoxContainer/size/z").value
	models[model_index].pivot.x = get_node("../../TopBar/VBoxContainer/pivot/x").value
	models[model_index].pivot.y = get_node("../../TopBar/VBoxContainer/pivot/y").value
	models[model_index].pivot.z = get_node("../../TopBar/VBoxContainer/pivot/z").value
	var scene = PackedScene.new()
	var voxel_root = Path.new()
	voxel_root.set_script(VOXEL_ROOT_SCRIPT)
	for model in models:
		print(model.get_child_count())
		print(model.get_parent())
		if(model.get_parent()):
			model.get_parent().remove_child(model)
		if(!model.get_parent()):
			voxel_root.add_child(model)
			model.owner = voxel_root
			for voxel in model.get_children():
				var color = get_material_color(voxel.color_index)
				voxel.color = color
				voxel.translation -= model.pivot
				voxel.owner = voxel_root
	var result = scene.pack(voxel_root)
	if result == OK:
		var name = get_node("../../TopBar/VBoxContainer/name/TextEdit").text + ".scn"
		ResourceSaver.save("res://voxel_models/"+name, scene)

func add_voxel(x,y,z,color_index,model = null):
	if(!model):
		model = get_current_model()
	if(!model.voxel_children.has(Vector3(x,y,z))):
		var voxel = VOXEL_SCENE.instance()
		var material = SpatialMaterial.new()
		material.flags_unshaded = true
		material.flags_albedo_tex_force_srgb = true
		voxel.color_index = color_index
		voxel.color = get_material_color(color_index)
		voxel.mesh.material = material
		voxel.material_override = material
		voxel.translation = Vector3(x,y,z)
		model.add_child(voxel)
		model.voxel_children[Vector3(x,y,z)] = voxel
	else:
		model.voxel_children[Vector3(x,y,z)].color_index = color_index
		model.voxel_children[Vector3(x,y,z)].color = get_material_color(color_index)

func on_import(file_path):
	models = []
	model_index = 0
	clear()
	refresh_materials()
	get_node("../../LeftSideBar/VBoxContainer/ColorPicker").refresh()
	var magica_voxel_file = _mvload(file_path)
	var palette = magica_voxel_file.palette
	var index = 0
	var used_colors = []
	get_node("../../TopBar/VBoxContainer/name/TextEdit").text = file_path.get_file().get_basename()
	for model in magica_voxel_file.models:
		var _model = VOXEL_MODEL_SCENE.instance()
		_model.size = Vector3(model.size.z,model.size.y,model.size.x)
		_model.pivot = Vector3(floor(_model.size.x/2),0,floor(_model.size.z/2))
		var voxel_positions = model.voxels.keys()
		get_node("../../TopBar/VBoxContainer/size/x").value = _model.size.x
		get_node("../../TopBar/VBoxContainer/size/y").value = _model.size.y
		get_node("../../TopBar/VBoxContainer/size/z").value = _model.size.z
		get_node("../../TopBar/VBoxContainer/pivot/x").value = _model.pivot.x
		get_node("../../TopBar/VBoxContainer/pivot/y").value = _model.pivot.y
		get_node("../../TopBar/VBoxContainer/pivot/z").value = _model.pivot.z
		for p in voxel_positions:
			var color_index = model.voxels[p]
			var color =  palette[color_index]
			if(used_colors.find(color) == -1):
				used_colors.append(color)
			var i = used_colors.find(color)
			get_node("../../LeftSideBar/VBoxContainer/ColorPicker").get_material(i).albedo_color = color
			theme.get_item_mesh(i).material = get_node("../../LeftSideBar/VBoxContainer/ColorPicker").get_material(i)
			_model.voxels[p] = i
			add_voxel(p.x,p.y,p.z,i,_model)
		models.append(_model)
	show_current_model()

func get_material_color(index):
	return theme.get_item_mesh(index).material.albedo_color


class Voxel:
	var position = Vector3(0,0,0)
	var color_index = 0

	func read(stream):
		position.z = stream.get_8()
		position.x = stream.get_8()
		position.y = stream.get_8()
		color_index = stream.get_8()-1

class STRING:
	var text = ""
	func read(stream):
		var buffer_size = stream.get_32()
		var arr = PoolByteArray([])
		for i in range(buffer_size):
			arr.append(stream.get_8())
		text = arr.get_string_from_ascii()

class MVDictionary:
	var dictionary = {}

	func read(stream):
		var key = STRING.new()
		key.read(stream)
		var value = null
		if(key.text == "_name"):
			value = STRING.new()
			value.read(stream)
		elif(key.text == "_hidden"):
			value = stream.get_buffer(1)[0]
		elif(key.text == "_r"):
			value = stream.get_8()
		elif(key.text == "_t"):
			value = Vector3(0,0,0)
			value.x = stream.get_32()
			value.y = stream.get_32()
			value.z = stream.get_32()
		dictionary[key] = value

class MVModel:
	var id
	var voxels
	var size

class MagicaVoxelFile:
	var models = null
	var palette = null

func _mvload(_path):
	var stream = File.new()
	stream.open(_path,1)
	var data = []
	var colors = []
	var voxelData = []
	var a = PoolByteArray([])
	for i in range(4):
		a.append(stream.get_8())
	var MAGIC = a.get_string_from_ascii()
	var VERSION = stream.get_32()

	var models = []
	var sizes = []
	if (MAGIC == "VOX "):
		var last_position = stream.get_position()
		while (stream.get_position() < stream.get_len()):
			a = PoolByteArray([])
			for i in range(4):
				a.append(stream.get_8())
			var CHUNK_ID = a.get_string_from_ascii()
			var CHUNK_SIZE = stream.get_32()
			var CHILD_CHUNKS = stream.get_32()
			var desired_position = stream.get_position() + CHUNK_SIZE
			var CHUNK_NAME = CHUNK_ID
			var numModels = 1
			if (CHUNK_NAME == "PACK"):
				numModels = stream.get_32()
			elif (CHUNK_NAME == "SIZE"):
				var sizex = stream.get_32()
				var sizez = stream.get_32()
				var sizey = stream.get_32()
				sizes.append(Vector3(sizex, sizey, sizez))
				for i in range(CHUNK_SIZE - 4 * 3):
					stream.get_8()
			elif (CHUNK_NAME == "XYZI"):
				var model = {}
				var numVoxels = stream.get_32()
				var div = 1
				for i in range(numVoxels):
					var vox = Voxel.new()
					vox.read(stream)
					model[vox.position] = vox.color_index
				models.append(model)
			elif (CHUNK_NAME == "RGBA"):
				colors = []
				for i in range(0,256):
					var color = Color8(stream.get_8(),stream.get_8(),stream.get_8(),stream.get_8())
					colors.append(color)
			stream.seek(desired_position)
	var MODELS = []
	for i in range(0,models.size()):
		var voxels = models[i]
		var model = MVModel.new()
		model.id = i
#		var culled_voxels = {}
#		for p in voxels.keys():
#			var bordered = 0
#			if(voxels.keys().has(p + Vector3(1,0,0))):
#				bordered += 1
#			if(voxels.keys().has(p + Vector3(-1,0,0))):
#				bordered += 1
#			if(voxels.keys().has(p + Vector3(0,1,0))):
#				bordered += 1
#			if(voxels.keys().has(p + Vector3(0,-1,0))):
#				bordered += 1
#			if(voxels.keys().has(p + Vector3(0,0,1))):
#				bordered += 1
#			if(voxels.keys().has(p + Vector3(0,0,-1))):
#				bordered += 1
#			if(bordered != 6):
#				culled_voxels[p] = voxels[p]
		model.voxels = voxels
		model.size = sizes[i]
		MODELS.append(model)
	var MVFILE = MagicaVoxelFile.new()
	MVFILE.models = MODELS
	MVFILE.palette = colors
	return MVFILE
