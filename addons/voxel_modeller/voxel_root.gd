tool
extends Spatial

export var model_index = 0

func _process(delta):
	for model in get_children():
		if(model.get_position_in_parent() != model_index):
			model.visible = false
		elif(!model.visible):
			model.visible = true