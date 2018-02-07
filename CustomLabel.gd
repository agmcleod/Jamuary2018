func create_label(camera_canvas, text):
	var label = Label.new()
	label.set_text(text)
	label.set_align(Label.ALIGN_CENTER)
	camera_canvas.add_child(label)
	var size = label.get_size()
	label.rect_position.x = 320 - size.x / 2
	label.rect_position.y = 240 - size.y / 2
	return label.get_path()
