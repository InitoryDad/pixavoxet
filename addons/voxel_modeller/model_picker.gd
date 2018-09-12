tool
extends SpinBox

func _process(delta):
	max_value = get_node("../Viewport/GridMap").models.size()-1