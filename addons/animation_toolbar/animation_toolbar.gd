tool
extends EditorPlugin

var panel
var animation_button
var animation_player
var play_button
var timeline
var animations
var filedialog

func _enter_tree():
	connect("scene_changed",self,"scene_changed")
	panel = HBoxContainer.new()
	timeline = HSlider.new()
	timeline.rect_min_size = Vector2(1000,32)
	timeline.max_value = .16
	timeline.step = .01
	timeline.connect("value_changed",self,"change_frame")
	play_button = Button.new()
	play_button.text = "Play"
	play_button.connect("pressed",self,"play")
	play_button.modulate = Color(0,1,0,1)
	var save_button = Button.new()
	save_button.text = "Render"
	save_button.connect("pressed",self,"render")
	save_button.modulate = Color(0,1,1,1)
	animation_button = OptionButton.new()
	animation_button.connect("item_selected",self,"animation_selected")
	panel.add_child(animation_button)
	panel.add_child(play_button)
	panel.add_child(save_button)
	panel.add_child(timeline)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_BOTTOM,panel)
	add_custom_type("VoxelRoot", "Spatial", preload("VoxelRoot.gd"), preload("voxel_root_icon.png"))

func scene_changed(scene):
	var scene_root = get_tree().get_edited_scene_root()
	animation_player = scene_root.get_node("AnimationPlayer")
	animation_button.clear()
	animations = animation_player.get_animation_list()
	if(animation_player.animation_name == ""):
		animation_player.animation_name = animations[0]
	var id = 0
	for anim in animations:
		animation_button.add_item(anim,id)
		id += 1
	animation_player.frame = 0
	animation_player.update()

func open_file():
	filedialog.visible = true

func change_frame(value):
	if(animation_player && !animation_player.rendering && animation_player.frame != value):
		animation_player.animation_name = animation_button.get_item_text(animation_button.get_selected_id())
		animation_player.current_animation = animation_button.get_item_text(animation_button.get_selected_id())
		animation_player.frame = value
		animation_player.update()

func animation_selected(idx):
	if(animation_player && !animation_player.rendering):
		var scene_root = get_tree().get_edited_scene_root()
		animation_player.animation_name = animation_button.get_item_text(idx)
		animation_player.current_animation = animation_button.get_item_text(idx)
		get_editor_interface().inspect_object(scene_root.get_node("AnimationPlayer"))
		timeline.max_value = animation_player.current_animation_length -.01
		timeline.value = animation_player.frame
		timeline.step = .01
		animation_player.frame = 0
		animation_player.update()
		print("selected")

func _process(delta):
	var scene_root = get_tree().get_edited_scene_root()
	if(scene_root && !animation_player && scene_root.get_node("AnimationPlayer") || animation_player && animation_player.get_animation_list() != animations):
		animation_player = scene_root.get_node("AnimationPlayer")
		animation_button.clear()
		animations = animation_player.get_animation_list()
		if(animation_player.animation_name == ""):
			animation_player.animation_name = animations[0]
		var id = 0
		for anim in animations:
			animation_button.add_item(anim,id)
			id += 1
		animation_player.frame = 0
		animation_player.update()
	if(scene_root && scene_root.get_node("AnimationPlayer") && animation_player && !animation_player.rendering):
		if(animation_player.current_animation != ""):
			timeline.max_value = animation_player.current_animation_length - .01
			timeline.value = animation_player.frame
			timeline.step = .01
	if(!scene_root || !scene_root.get_node("AnimationPlayer")):
		animation_player = null

func render():
	if(animation_player):
		var vp = get_tree().get_edited_scene_root().get_node("ViewportContainer/Viewport")
		vp.save_start()


func play():
	if(animation_player):
		animation_player.play = !animation_player.play
		if(!animation_player.play && !animation_player.rendering):
			animation_player.stop(false)
			play_button.set_text("Play")
			play_button.modulate = Color(0,1,0,1)
		if(animation_player.play && !animation_player.rendering):
			animation_player.animation_name = animation_button.get_item_text(animation_button.get_selected_id())
			animation_player.current_animation = animation_button.get_item_text(animation_button.get_selected_id())
			play_button.set_text("Pause")
			play_button.modulate = Color(1,0,0,1)

func _exit_tree():
	remove_custom_type("VoxelRoot")
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_BOTTOM,panel)
	panel.free()