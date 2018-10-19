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
	timeline.rect_min_size = Vector2(900,32)
	timeline.max_value = 16
	timeline.step = 1
	timeline.connect("value_changed",self,"change_frame")
	play_button = Button.new()
	play_button.text = "Play"
	play_button.connect("pressed",self,"play")
	play_button.modulate = Color(0,1,0,1)
	var render_all_button = Button.new()
	render_all_button.text = "Render All"
	render_all_button.connect("pressed",self,"render_all")
	render_all_button.modulate = Color(0,1,1,1)
	var render_button = Button.new()
	render_button.text = "Render"
	render_button.connect("pressed",self,"render")
	render_button.modulate = Color(0,1,1,1)
	animation_button = OptionButton.new()
	animation_button.connect("item_selected",self,"animation_selected")
	panel.add_child(animation_button)
	panel.add_child(play_button)
	panel.add_child(render_button)
	panel.add_child(render_all_button)
	panel.add_child(timeline)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_BOTTOM,panel)

func scene_changed(scene):
	var scene_root = get_tree().get_edited_scene_root()
	if(get_tree().get_nodes_in_group("frame_by_frame_helper").size() == 0):
		return
	animation_player = get_tree().get_nodes_in_group("frame_by_frame_helper")[0]
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
		get_editor_interface().inspect_object(get_tree().get_nodes_in_group("frame_by_frame_helper")[0])
		timeline.max_value = animation_player.current_animation_length - animation_player.frame_step
		timeline.value = animation_player.frame
		timeline.step = animation_player.frame_step
		animation_player.frame = 0
		animation_player.update()

func _process(delta):
	var scene_root = get_tree().get_edited_scene_root()

	if(!scene_root || get_tree().get_nodes_in_group("frame_by_frame_helper").size() == 0):
		return
	if(scene_root && !animation_player && get_tree().get_nodes_in_group("frame_by_frame_helper").size() > 0 || animation_player && animation_player.get_animation_list() != animations):
		animation_player = get_tree().get_nodes_in_group("frame_by_frame_helper")[0]
		if(!animation_player):
			return
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
	if(scene_root && get_tree().get_nodes_in_group("frame_by_frame_helper").size() > 0 && animation_player && !animation_player.rendering):
		if(animation_player.current_animation != ""):
			timeline.max_value = animation_player.current_animation_length - animation_player.frame_step
			timeline.value = animation_player.frame
			timeline.step = animation_player.frame_step
	if(!scene_root || get_tree().get_nodes_in_group("frame_by_frame_helper").size() == 0):
		animation_player = null

func render_all():
	if(animation_player):
		var vp = get_tree().get_nodes_in_group("spritesheet_renderer")[0]
		vp.save_start(true)

func render():
	if(animation_player):
		var vp = get_tree().get_nodes_in_group("spritesheet_renderer")[0]
		vp.save_start(false)


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
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_BOTTOM,panel)
	panel.visible = false
	for child in panel.get_children():
		child.free()
	panel.free()
