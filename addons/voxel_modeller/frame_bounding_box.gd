tool
extends MeshInstance

export var render_bottom = true
export var render_top = false
export var render_side_1 = true
export var render_side_2 = true
export var render_side_3 = true
export var render_side_4 = true

func _process(delta):
	translation.x = get_parent().size/2*-1
	translation.y = get_parent().size/2*-1
	var material = SpatialMaterial.new()
	material.vertex_color_use_as_albedo = true
	material.flags_unshaded = true
	material.flags_transparent = true
	var size = Vector3(get_parent().size,get_parent().size,-1*translation.z)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	#bottom-xz-red-blue
	if(render_bottom):
		st.add_color(Color(0, 0, 1, .5))
		for x in range(0,size.x + 1,size.x):
			st.add_vertex(Vector3(x, 0, 0))
			st.add_vertex(Vector3(x, 0, size.z))
		for z in range(0,size.z + 1,size.z):
			st.add_vertex(Vector3(0, 0, z))
			st.add_vertex(Vector3(size.x, 0, z))
	if(render_top):
		st.add_color(Color(0, 1, 0, .5))
		for x in range(0,size.x + 1,size.x):
			st.add_vertex(Vector3(x, size.y, 0))
			st.add_vertex(Vector3(x, size.y, size.z))
		for z in range(0,size.z + 1,size.z):
			st.add_vertex(Vector3(0, size.y, z))
			st.add_vertex(Vector3(size.x, size.y, z))
	#side-xy-red-green
	if(render_side_1):
		st.add_color(Color(1, 1, 1, .5))
		for x in range(0,size.x + 1,size.x):
			st.add_vertex(Vector3(x, 0, 0))
			st.add_vertex(Vector3(x, size.y, 0))
		for y in range(0,size.y + 1,size.y):
			st.add_vertex(Vector3(0, y, 0))
			st.add_vertex(Vector3(size.x, y, 0))
	#side-zy-blue-green
	if(render_side_2):
		st.add_color(Color(1, 1, 1, .5))
		for z in range(0,size.z + 1,size.z):
			st.add_vertex(Vector3(0, 0, z))
			st.add_vertex(Vector3(0, size.y, z))
		for y in range(0,size.y + 1,size.y):
			st.add_vertex(Vector3(0, y, 0))
			st.add_vertex(Vector3(0, y, size.z))
	if(render_side_3):
		st.add_color(Color(1, 1, 1, .5))
		for y in range(0,size.y + 1,size.y):
			st.add_vertex(Vector3(0, y, size.z))
			st.add_vertex(Vector3(size.x, y, size.z))
		for x in range(0,size.x + 1,size.x):
			st.add_vertex(Vector3(x, 0, size.z))
			st.add_vertex(Vector3(x, size.y, size.z))
	if(render_side_4):
		st.add_color(Color(1, 1, 1, .5))
		for z in range(0,size.z + 1,size.z):
			st.add_vertex(Vector3(size.x, 0, z))
			st.add_vertex(Vector3(size.x, size.y, z))
		for y in range(0,size.y + 1,size.y):
			st.add_vertex(Vector3(size.x, y, 0))
			st.add_vertex(Vector3(size.x, y, size.z))
	st.set_material(material)
	mesh = st.commit()