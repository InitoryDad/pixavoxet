tool
extends AnimationPlayer

export var play = false
export var speed = .1
export var frame = 0.0
var animation_name = ""
var wait = 0.0
var next_frame = false
var rendering = false

func _ready():
	get_node("Timer").connect('timeout',self,'next_frame')
	stop()

func _process(delta):
	get_node("Timer").wait_time = speed
	if(play):
		print("hi")
		get_node("Timer").start()
		#next_frame()
	elif(!play && is_playing() && !rendering):
		get_node("Timer").stop()
		stop()

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

