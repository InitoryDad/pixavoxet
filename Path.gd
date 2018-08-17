tool
extends Path

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
func _process(delta):
	print(curve.get_baked_length())