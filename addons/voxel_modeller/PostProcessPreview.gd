tool
extends Sprite3D

export var export_directory = "res://renders"
export var frame_size = 32
export var outline_color = Color(0,0,0,1)
export var remove_jags = false
export var render_inner_outline = true
export(NodePath) var camera_path

var frame_count = 0
var last_position = 0
var last_image = null
var rendered_frames = []


func _process(delta):
	$Viewport.size = Vector2(frame_size,frame_size)
	$Viewport/Sideview.size = frame_size
	if(visible):
		outline_pass()

func get_visible_voxels():
	var camera = get_node(camera_path)
	var h = frame_size
	var w = frame_size
	var _voxels = []
	for x in range(0,w+1):
		for y in range(0,h+1):
			var pos = Vector2(x,y)
			var ray_origin = camera.project_ray_origin(pos)
			var ray_direction = camera.project_ray_normal(pos)
			var from = ray_origin - Vector3(.5,.25,.5)
			var to = ray_origin + ray_direction * 1000000.0
			var state = camera.get_world().direct_space_state
			var hit = state.intersect_ray(from,to,[],1)
			if(!hit.empty()):
				if(hit.collider.get_parent().is_visible_in_tree()):
					_voxels.append(hit.collider.get_parent())
	return _voxels

func outline_pass():
	var camera = get_node(camera_path)
	var image = Image.new()
	image.create(frame_size,frame_size,false,5)
	var h = frame_size
	var w = frame_size
	image.lock()
	var outline = []
	for x in range(0,w+1):
		for y in range(0,h+1):
			var pos = Vector2(x,y)
			var ray_origin = camera.project_ray_origin(pos)
			var ray_direction = camera.project_ray_normal(pos)
			var from = ray_origin - Vector3(.5,.25,.5)
			var to = ray_origin + ray_direction * 1000000.0
			var state = camera.get_world().direct_space_state
			var hit = state.intersect_ray(from,to,[],1)
			if(!hit.empty()):
				if(hit.collider.get_parent().is_visible_in_tree()):
					image.set_pixel(pos.x,h-pos.y,hit.collider.get_parent().material_override.albedo_color)
					if(render_inner_outline):
						var checks = [Vector2(x+1,y), Vector2(x-1,y), Vector2(x,y+1), Vector2(x,y-1)]
						for p in checks:
							ray_origin = camera.project_ray_origin(p)
							ray_direction = camera.project_ray_normal(p)
							from = ray_origin
							to = ray_origin + ray_direction * 1000000.0
							var hit2 = state.intersect_ray(from,to,[],1)
							if(!hit2.empty()):
								if(hit2.collider.get_parent().is_visible_in_tree()):
									if(hit.collider.get_parent() != hit2.collider.get_parent() && hit.position.x - hit2.position.x > 2.4):
										var c = image.get_pixel(pos.x,h-pos.y)
										if(c.a != 0):
											image.set_pixel(pos.x,h-pos.y,c.darkened(.5))
											break
	if(remove_jags):
		var remove = []
		for x in range(0,w):
			for y in range(0,h):
				var c = image.get_pixel(x,y)
				var bordering = 0
				var u; var d; var l; var r;
				if(y-1 >= 0):
					u = image.get_pixel(x,y-1)
					if(u.a != 0):
						bordering += 1
				if(y+1 < h):
					d = image.get_pixel(x,y+1)
					if(d.a != 0):
						bordering += 1
				if(x-1 >= 0):
					l = image.get_pixel(x-1,y)
					if(l.a != 0):
						bordering += 1
				if(x+1 < w):
					r = image.get_pixel(x+1,y)
					if(r.a != 0):
						bordering += 1
				if(bordering < 2):
					remove.append(Vector2(x,y))
		for xy in remove:
			image.set_pixel(xy.x,xy.y,Color(0,0,0,0))
	for x in range(0,w):
		for y in range(0,h):
			var c = image.get_pixel(x,y)
			var bordering = 0
			var u; var d; var l; var r;
			if(y-1 >= 0):
				u = image.get_pixel(x,y-1)
				if(u.a != 0):
					bordering += 1
			if(y+1 < h):
				d = image.get_pixel(x,y+1)
				if(d.a != 0):
					bordering += 1
			if(x-1 >= 0):
				l = image.get_pixel(x-1,y)
				if(l.a != 0):
					bordering += 1
			if(x+1 < w):
				r = image.get_pixel(x+1,y)
				if(r.a != 0):
					bordering += 1
			if(c.a == 0):
				if(u && u.a != 0 || d && d.a != 0 || l && l.a != 0 || r && r.a != 0 || bordering > 0):
					outline.append(Vector2(x,y))
	for xy in outline:
		image.set_pixel(xy.x,xy.y,outline_color)
	image.flip_y()
	image.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(image,2)
	texture = tex
	return image

func save_start():
	var animation_player = get_tree().get_nodes_in_group("frame_by_frame_helper")[0]
	animation_player.rendering = true
	yield(get_tree(),"idle_frame")
	var animation_list = animation_player.get_animation_list()
	for anim in animation_list:
		rendered_frames = []
		animation_player.animation_name = anim
		animation_player.play(anim)
		animation_player.playback_speed = 0
		animation_player.frame = animation_player.current_animation_length - 1
		animation_player.next_frame()
		animation_player.update()
		for i in range(0,1):
			yield(get_tree(),"idle_frame")
		for i in range(0, animation_player.current_animation_length / 1):
			save(anim, animation_player)
			animation_player.next_frame()
			for i in range(0,1):
				yield(get_tree(),"idle_frame")
		save_spritesheet(animation_player, anim)
		frame_count = 0
	animation_player.rendering = false
	yield(get_tree(),"idle_frame")

func save_spritesheet(player,animation_name):
	var dir = Directory.new()
	var directories = export_directory
	dir.make_dir_recursive(directories)
	var colrow = ceil(sqrt(player.current_animation_length / 1))
	var xinc = rendered_frames[0].get_width()
	var yinc = rendered_frames[0].get_height()
	var w = rendered_frames[0].get_width() * colrow
	var h = rendered_frames[0].get_height() * colrow
	var image = Image.new()
	image.create(w,h,false,Image.FORMAT_RGBA8)
	var i = 0
	for y in range(0,colrow):
		for x in range(0,colrow):
			if(i < rendered_frames.size()):
				image.blit_rect(rendered_frames[i],Rect2(0,0, xinc, yinc),Vector2(x * xinc, y * yinc))
			i += 1
	print("saving: ", directories + "/" + animation_name +".png")
	image.save_png(directories + "/" + animation_name +".png")

func save(name, player):
	var image = outline_pass()
	#image.save_png(directories + "/" +name + "_" + str(frame_count)+".png")
	frame_count += 1
	rendered_frames.append(image)