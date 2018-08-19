tool
extends AnimationPlayer

export var play = false
export var speed = 0.1
export var frame = 0.0
var animation_name = ""
var wait = 0.0
var next_frame = false
var rendering = false
var elapsed = 0
func _ready():
	stop(false)

func _process(delta):
	if(play && elapsed > speed):
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
		frame += .01
		if(frame >= current_animation_length):
			frame = 0
		update()

func update():
	seek(frame,true)
	yield(get_tree(),"idle_frame")

func get_node_path(path):
	var s = ""
	for i in path.get_name_count():
		s = s + path.get_name(i) + "/"
	return s

