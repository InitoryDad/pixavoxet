tool
extends VBoxContainer

var group = ButtonGroup.new()

func _process(delta):
	if(get_child_count() < get_node("../../../Viewport/GridMap").models.size()):
		var button = Button.new()
		button.group = group
		add_child(button)
		button.text = "model " + str(button.get_position_in_parent())
		button.connect("pressed",get_node("../../../Viewport/GridMap"),"set_model_index",[button.get_position_in_parent()])
	if(get_child_count() > get_node("../../../Viewport/GridMap").models.size()):
		var last = get_child(get_child_count()-1)
		remove_child(last)
		last.free()