tool
extends AnimationPlayer

export var play = false
export var speed = 0.1
export var frame_step = 1.0
export var frame = 0
var animation_name = ""
var wait = 0.0
var next_frame = false
var rendering = false
var elapsed = 0.0

func _ready():
	play = false
	animation_name = ""
	wait = 0.0
	next_frame = false
	rendering = false
	elapsed = 0.0
	stop(true)

func _process(delta):
	if(play && elapsed > speed):
		stop(false)
		elapsed = 0
		next_frame()
	elif(!play && is_playing() && !rendering):
		yield(get_tree(),"idle_frame")
		elapsed = 0
		stop(false)
	if(play):
		elapsed += delta

func next_frame():
	if(animation_name != ""):
		frame += frame_step
		if(frame >= current_animation_length):
			frame = 0
		update()

func update():
	seek(frame,true)
	#advance(frame_step)

func get_node_path(path):
	var s = ""
	for i in path.get_name_count():
		s = s + path.get_name(i) + "/"
	return s

