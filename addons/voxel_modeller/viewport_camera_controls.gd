tool
extends ViewportContainer

var Voxel = preload("res://voxel.tscn")

var zooming_in = false
var zooming_out = false
var rotating = false
var panning = false
onready var camera = $Viewport/Camera
onready var temp_box = $Viewport/TempBox
onready var cursor = $Viewport/Cursor
onready var gridmap = $Viewport/GridMap
onready var matrix = get_node("Viewport/GridMap/Matrix")
var toolmode = "box"
var temp_voxels = []
var drag_box = null
var drag_start = false
var drag_end = false
var thread = Thread.new()

func _ready():
	PhysicsServer.set_active(true)

func zoom(delta):
	camera.size += delta

func _physics_process(delta):
	camera = $Viewport/Camera
	temp_box = $Viewport/TempBox
	cursor = $Viewport/Cursor
	gridmap = $Viewport/GridMap
	matrix = get_node("Viewport/GridMap/Matrix")
	while(temp_voxels.size() > 0):
		var pos = temp_voxels.front()
		if(gridmap.get_cell_item(pos.x,pos.y,pos.z) != -1):
			gridmap.set_cell_item(pos.x,pos.y,pos.z,-1)
		temp_voxels.pop_front()
	yield(get_tree(),"idle_frame")
	var mouse_pos = get_node("Viewport").get_mouse_position()
	var box = matrix.box
	var size = matrix.box.size
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var from = ray_origin
	var to = ray_origin + ray_direction * 1000000.0
	yield(get_tree(),"idle_frame")
	var state = camera.get_world().direct_space_state
	var hit = state.intersect_ray(from,to)
	if(!hit.empty()):
		var p = hit.position + (hit.normal.round() * .5)
		p = p.floor()
		p += Vector3(.5,.5,.5)
		cursor.translation = p
		if(drag_start && drag_box == null):
			p = hit.position + (hit.normal.round() * .5)
			p = p.floor()
			p.x = min(size.x-1,p.x)
			p.x = max(0,p.x)
			p.y = min(size.y-1,p.y)
			p.y = max(0,p.y)
			p.z = min(size.z-1,p.z)
			p.z = max(0,p.z)
			drag_box = [p,p]
		if(drag_start):
			p = hit.position + (hit.normal.round() * .5)
			p = p.floor()
			p.x = min(size.x-1,p.x)
			p.x = max(0,p.x)
			p.y = min(size.y-1,p.y)
			p.y = max(0,p.y)
			p.z = min(size.z-1,p.z)
			p.z = max(0,p.z)
			if(get_area(p) < 100):
				drag_box[1] = p
	if(drag_box):
		place_drag_box(true)

func pan(ev):
	var t = camera.transform.orthonormalized()
	t = t.translated(Vector3(1,0,0) * -ev.relative.x * .05)
	t = t.translated(Vector3(0,1,0) * ev.relative.y * .05)
	camera.transform = t

func rotate(ev):
	var cam_c = camera
	var y = cam_c.transform.basis.y.y
	var trans = cam_c.translation
	if(abs(ev.relative.y) > abs(ev.relative.x)):
		var t = cam_c.global_transform.orthonormalized()
		t = t.rotated(-t.basis.x,-ev.relative.y * .005)
		if(t.basis.y.y > 0):
			cam_c.global_transform = t
		else:
			t = cam_c.global_transform.orthonormalized()
			t = t.rotated(-Vector3(0,1,0),ev.relative.y * .005)
			cam_c.transform = t
	else:
		var t = cam_c.transform.orthonormalized()
		t = t.rotated(-Vector3(0,1,0),ev.relative.x * .005)
		cam_c.transform = t

func gui_input(ev):
	if(ev is InputEventMouseButton && ev.button_index == BUTTON_WHEEL_UP):
		zoom(-1)
	if(ev is InputEventMouseButton && ev.button_index == BUTTON_WHEEL_DOWN):
		zoom(1)
	if(ev is InputEventMouseButton && ev.button_index == BUTTON_RIGHT && ev.pressed):
		rotating = true
	if(ev is InputEventMouseButton && ev.button_index == BUTTON_RIGHT && !ev.pressed):
		rotating = false
	if(ev is InputEventMouseButton && ev.button_index == BUTTON_MIDDLE && ev.pressed):
		panning = true
	if(ev is InputEventMouseButton && ev.button_index == BUTTON_MIDDLE && !ev.pressed):
		panning = false
	if(ev is InputEventMouseMotion && rotating && !ev.is_echo()):
		rotate(ev)
	if(ev is InputEventMouseMotion && panning && !ev.is_echo()):
		pan(ev)
	if(toolmode == "box"):
		if(ev is InputEventMouseButton && ev.button_index == 1 && ev.pressed && !ev.is_echo()):
			#temp_box.visible = true
			drag_start = true
			drag_end = false
#			p = hit.position + (hit.normal.round() * .5)
#			p = p.floor()
#			p.x = min(size.x-1,p.x)
#			p.x = max(0,p.x)
#			p.y = min(size.y-1,p.y)
#			p.y = max(0,p.y)
#			p.z = min(size.z-1,p.z)
#			p.z = max(0,p.z)
#			drag_box[0] = p
		if(ev is InputEventMouseButton && ev.button_index == 1 && !ev.pressed && !ev.is_echo()):
			#temp_box.visible = false
			drag_start = false
			drag_end = true
#				var index = get_node("Panel/VBoxContainer/ColorPicker").selected_index
#				var color = get_node("Panel/VBoxContainer/ColorPicker").get_selected_material()
#				var min_x = min(drag_box[0].x,drag_box[1].x)
#				var min_y = min(drag_box[0].y,drag_box[1].y)
#				var min_z = min(drag_box[0].z,drag_box[1].z)
#				var max_x = max(drag_box[0].x,drag_box[1].x)
#				var max_y = max(drag_box[0].y,drag_box[1].y)
#				var max_z = max(drag_box[0].z,drag_box[1].z)
#				for x in range(min_x, max_x+1):
#					for y in range(min_y, max_y+1):
#						for z in range(min_z, max_z+1):
#							if(gridmap.get_cell_item(x,y,z) == -1):
#								gridmap.theme.get_item_mesh(index).material = color
#								gridmap.set_cell_item(x,y,z,index)
#								temp_voxels.append(Vector3(x,y,z))
#				temp_box.mesh.material = color
#				temp_box.translation = Vector3(min_x,min_y,min_z) + (Vector3(max_x,max_y,max_z) - Vector3(min_x,min_y,min_z)  + Vector3(1,1,1) )/2
#				temp_box.mesh.size = Vector3(max_x,max_y,max_z) - Vector3(min_x,min_y,min_z) + Vector3(1,1,1)
		if(drag_end):
			drag_box = null
#				for pos in temp_voxels:
#			#		if(!in_box(pos)):
#					gridmap.set_cell_item(pos.x,pos.y,pos.z,-1)
#					temp_voxels.remove(temp_voxels.find(pos))
			temp_voxels = []
			place_drag_box(false)
			drag_end = false

func get_area(pos):
	var min_x = min(drag_box[0].x,pos.x)
	var min_y = min(drag_box[0].y,pos.y)
	var min_z = min(drag_box[0].z,pos.z)
	var max_x = max(drag_box[0].x,pos.x)
	var max_y = max(drag_box[0].y,pos.y)
	var max_z = max(drag_box[0].z,pos.z)
	var area = (max_x - min_x) * (max_y - min_y) * (max_z - min_z)
	return area

func place_drag_box(temp):
	var box = matrix.box
	var size = matrix.box.size
	var color = get_node("Panel/VBoxContainer/ColorPicker").get_selected_material()
	var index = get_node("Panel/VBoxContainer/ColorPicker").selected_index
	var min_x = min(drag_box[0].x,drag_box[1].x)
	var min_y = min(drag_box[0].y,drag_box[1].y)
	var min_z = min(drag_box[0].z,drag_box[1].z)
	var max_x = max(drag_box[0].x,drag_box[1].x)
	var max_y = max(drag_box[0].y,drag_box[1].y)
	var max_z = max(drag_box[0].z,drag_box[1].z)
	var voxels = []
	for x in range(min_x, max_x+1):
		for y in range(min_y, max_y+1):
			for z in range(min_z, max_z+1):
				if(gridmap.get_cell_item(x,y,z) == -1):
					gridmap.theme.get_item_mesh(index).material = color
					voxels.append(Vector3(x,y,z))
					if(temp):
						temp_voxels.append(Vector3(x,y,z))
	for p in voxels:
		gridmap.set_cell_item(p.x,p.y,p.z,index)