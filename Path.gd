tool
extends Path

var last_length = 0
func _process(delta):
	if(round(curve.get_baked_length()) != last_length):
		last_length = round(curve.get_baked_length())