tool
extends Sprite3D

export var outline_color = Color(0,0,0,1)
export var remove_jags = false
export var render_inner_outline = true

func _process(delta):
	var image = get_parent().get_node("Viewport").get_texture().get_data()
	outline_pass(image)

func outline_pass(image):
	var h = image.get_height()
	var w = image.get_width()
	image.lock()
	var outline = []
	var camera = $"../Viewport/Sideview"
	for x in range(0,w):
		for y in range(0,h):
			var pos = Vector2(x,y)
			var ray_origin = camera.project_ray_origin(pos)
			var ray_direction = camera.project_ray_normal(pos)
			#ray_origin = ray_origin.round()
			var from = ray_origin
			var to = ray_origin + ray_direction * 1000000.0
			var state = camera.get_world().direct_space_state
			var hit = state.intersect_ray(from,to)
			if(!hit.empty()):
				if(hit.collider.get_parent().is_visible_in_tree()):
					image.set_pixel(pos.x,h-pos.y,hit.collider.get_parent().material_override.albedo_color)
					if(render_inner_outline):
						var checks = [Vector2(x+1,y), Vector2(x-1,y), Vector2(x,y+1), Vector2(x,y-1)]
						for p in checks:
							ray_origin = camera.project_ray_origin(p)
							#ray_origin = ray_origin.round()
							ray_direction = camera.project_ray_normal(p)
							from = ray_origin
							to = ray_origin + ray_direction * 1000000.0
							var hit2 = state.intersect_ray(from,to)
							if(!hit2.empty()):
								if(hit2.collider.get_parent().is_visible_in_tree()):
									if(hit.collider.get_parent() != hit2.collider.get_parent() && hit.position.x - hit2.position.x > 2):
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
				elif(get_parent().get_node("Viewport").noise):
					var noise_strength = get_parent().get_node("Viewport").noise_strength
					c.r += rand_range(-noise_strength,noise_strength)
					c.g += rand_range(-noise_strength,noise_strength)
					c.b += rand_range(-noise_strength,noise_strength)
					image.set_pixel(x,y,c)
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
	image.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(image,2)
	texture = tex