tool
extends Viewport

export var export_directory = ""
export var outline_color = Color(0,0,0,1)
var frame_count = 0
var last_position = 0
var last_image = null
var rendered_frames = []

func save_start():
	var animation_player = get_tree().get_edited_scene_root().get_node("AnimationPlayer")
	animation_player.rendering = true
	yield(get_tree(),"idle_frame")
	var animation_list = animation_player.get_animation_list()
	for anim in animation_list:
		rendered_frames = []
		animation_player.animation_name = anim
		animation_player.play(anim)
		animation_player.playback_speed = 0
		animation_player.frame = animation_player.current_animation_length - .01
		animation_player.next_frame()
		animation_player.update()
		for i in range(0,1):
			yield(get_tree(),"idle_frame")
		for i in range(0, animation_player.current_animation_length / .01):
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
	var colrow = ceil(sqrt(player.current_animation_length / .01))
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
#
func get_outlined_image():
	var image = get_texture().get_data()
	image.flip_y()
	var h = image.get_height()
	var w = image.get_width()
	image.lock()
	var outline = []
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
				image.set_pixel(x,y,Color(0,0,0,0))
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
	return image

func save(name, player):
	var image = get_outlined_image()
	#image.save_png(directories + "/" +name + "_" + str(frame_count)+".png")
	frame_count += 1
	rendered_frames.append(image)
#
#func close():
#	get_tree().quit()
