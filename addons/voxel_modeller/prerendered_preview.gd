tool
extends Sprite3D

export var frame_index = 0
export var speed = .1
var elapsed = 0.0

func _process(delta):
	if(elapsed > speed):
		elapsed = 0
		var frames = $"../FramePreview".rendered_frames
		if(frame_index < frames.keys().size() && frames.has(float(frame_index))):
			print(frame_index)
			var tex = ImageTexture.new()
			tex.create_from_image(frames[float(frame_index)],2)
			texture = tex
		frame_index += 1
		if(frame_index >= 8):
			frame_index = 0
	elapsed += delta
