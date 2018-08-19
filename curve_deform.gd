tool
extends Path

func _process(delta):
	var index = 0
	curve.clear_points()
	for point in get_children():
		curve.add_point(point.transform.origin, Vector3(),Vector3(), index)
		index += 1
