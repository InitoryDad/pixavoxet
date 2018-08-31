tool
extends MeshInstance
export var box = AABB(Vector3(0,0,0), Vector3(10,10,10))
var matrix = {}
var render_side_1 = false
var render_side_2 = false
var render_side_3 = false
var render_side_4 = false
var render_bottom = false
var render_top = false


func create_end_plane():
	var size = box.size
	var vec1 = Vector3(size.x/2,0,size.z/2)
	var vec2 = Vector3(-size.x/2,0,size.z/2)
	var vec3 = Vector3(-size.x/2,0,-size.z/2)
	var vec4 = Vector3(size.x/2,0,-size.z/2)
	return [vec1,vec2,vec3,vec4]

func create_side_plane_x():
	var size = box.size
	var vec1 = Vector3(0,size.y/2,size.z/2)
	var vec2 = Vector3(0,-size.y/2,size.z/2)
	var vec3 = Vector3(0,-size.y/2,-size.z/2)
	var vec4 = Vector3(0,size.y/2,-size.z/2)
	return [vec1,vec2,vec3,vec4]

func create_side_plane_z():
	var size = box.size
	var vec1 = Vector3(size.x/2,size.y/2,0)
	var vec2 = Vector3(-size.x/2,size.y/2,0)
	var vec3 = Vector3(-size.x/2,-size.y/2,0)
	var vec4 = Vector3(size.x/2,-size.y/2,0)
	return [vec1,vec2,vec3,vec4]


func setup_boundaries():
	var size = box.size
	var n = Vector3(size.x/2,0,size.z/2)
	get_node("Area/bottom").shape.points = create_end_plane()
	n = Vector3(size.x/2,size.y/2,0)
	get_node("Area/side1").shape.points = create_side_plane_z()
	n = Vector3(0,size.y/2,size.z/2)
	get_node("Area/side2").shape.points = create_side_plane_x()

func _process(delta):
	matrix_update()
	var size = box.size
	setup_boundaries()
	var material = SpatialMaterial.new()
	material.vertex_color_use_as_albedo = true
	material.flags_unshaded = true
	material.flags_transparent = true
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_LINES)
	#bottom-xz-red-blue
	if(render_bottom):
		st.add_color(Color(0, 0, 1, .5))
		var n = Vector3(size.x/2,0,size.z/2)
		get_node("Area/bottom").translation = n
		for x in size.x + 1:
			st.add_vertex(Vector3(x, 0, 0))
			st.add_vertex(Vector3(x, 0, size.z))
		for z in size.z + 1:
			st.add_vertex(Vector3(0, 0, z))
			st.add_vertex(Vector3(size.x, 0, z))
	if(render_top):
		st.add_color(Color(0, 1, 0, .5))
		var n = Vector3(size.x/2,0,size.z/2)
		get_node("Area/bottom").translation =  n + Vector3(0,size.y,0)
		for x in size.x + 1:
			st.add_vertex(Vector3(x, size.y, 0))
			st.add_vertex(Vector3(x, size.y, size.z))
		for z in size.z + 1:
			st.add_vertex(Vector3(0, size.y, z))
			st.add_vertex(Vector3(size.x, size.y, z))
	#side-xy-red-green
	if(render_side_1):
		st.add_color(Color(1, 1, 1, .5))
		var n = Vector3(size.x/2,size.y/2,0)
		get_node("Area/side1").translation = n
		for x in size.x + 1:
			st.add_vertex(Vector3(x, 0, 0))
			st.add_vertex(Vector3(x, size.y, 0))
		for y in size.y + 1:
			st.add_vertex(Vector3(0, y, 0))
			st.add_vertex(Vector3(size.x, y, 0))
	#side-zy-blue-green
	if(render_side_2):
		st.add_color(Color(1, 1, 1, .5))
		var n = Vector3(0,size.y/2,size.z/2)
		get_node("Area/side2").translation = n
		for z in size.z + 1:
			st.add_vertex(Vector3(0, 0, z))
			st.add_vertex(Vector3(0, size.y, z))
		for y in size.y + 1:
			st.add_vertex(Vector3(0, y, 0))
			st.add_vertex(Vector3(0, y, size.z))
	if(render_side_3):
		st.add_color(Color(1, 1, 1, .5))
		var n = Vector3(size.x/2,size.y/2,0)
		get_node("Area/side1").translation = n + Vector3(0,0,size.z)
		for y in size.y + 1:
			st.add_vertex(Vector3(0, y, size.z))
			st.add_vertex(Vector3(size.x, y, size.z))
		for x in size.x + 1:
			st.add_vertex(Vector3(x, 0, size.z))
			st.add_vertex(Vector3(x, size.y, size.z))
	if(render_side_4):
		st.add_color(Color(1, 1, 1, .5))
		var n = Vector3(0,size.y/2,size.z/2)
		get_node("Area/side2").translation = n + Vector3(size.x,0,0)
		for z in size.z + 1:
			st.add_vertex(Vector3(size.x, 0, z))
			st.add_vertex(Vector3(size.x, size.y, z))
		for y in size.y + 1:
			st.add_vertex(Vector3(size.x, y, 0))
			st.add_vertex(Vector3(size.x, y, size.z))
	st.set_material(material)
	mesh = st.commit()

func matrix_update():
	var camera = get_parent().get_parent().get_node("Camera")
	var rotation_degrees = camera.transform.basis.get_euler()
	rotation_degrees.x = rad2deg(rotation_degrees.x)
	rotation_degrees.y = rad2deg(rotation_degrees.y)
	rotation_degrees.z = rad2deg(rotation_degrees.z)
	if(rotation_degrees != Vector3(0,0,0)):
		if(rotation_degrees.y > 90 || rotation_degrees.y < -90):
			render_side_1 = false
			render_side_3 = true
		else:
			render_side_1 = true
			render_side_3 = false
		if(rotation_degrees.y < 0):
			render_side_2 = false
			render_side_4 = true
		else:
			render_side_2 = true
			render_side_4 = false
		if(rotation_degrees.x > 0):
			render_bottom = false
			render_top = true
		else:
			render_bottom = true
			render_top = false
