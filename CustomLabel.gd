func create_label(camera_canvas, text):
	var label = Label.new()
	label.set_text(text)
	label.set_align(Label.ALIGN_CENTER)
	camera_canvas.add_child(label)
	var size = label.get_size()
	label.set_pos(Vector2(320 - size.x / 2, 240 - size.y / 2))
	return label.get_path()
