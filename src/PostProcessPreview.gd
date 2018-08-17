tool
extends Sprite3D

export var outline_color = Color(0,0,0,1)
export var remove_jags = false

func _process(delta):
	var image = get_parent().get_node("Viewport").get_texture().get_data()
	outline_pass(image)

func outline_pass(image):
	var h = image.get_height()
	var w = image.get_width()
	image.lock()
	var outline = []
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
				if(bordering == 1):
					remove.append(Vector2(x,y))
				elif(get_parent().get_node("Viewport").noise):
					var noise_strength = get_parent().get_node("Viewport").noise_strength
					c.r += rand_range(-noise_strength,noise_strength)
					c.g += rand_range(-noise_strength,noise_strength)
					c.b += rand_range(-noise_strength,noise_strength)
					image.set_pixel(x,y,c)
		for xy in remove:
			image.set_pixel(xy.x,xy.y,Color(0,0,0,1))
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
				if(u && u.a != 0 || d && d.a != 0 || l && l.a != 0 || r && r.a != 0):
					outline.append(Vector2(x,y))
	for xy in outline:
		image.set_pixel(xy.x,xy.y,outline_color)
	image.unlock()
	var tex = ImageTexture.new()
	tex.create_from_image(image,2)
	texture = tex