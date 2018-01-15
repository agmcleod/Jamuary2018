extends "Hover.gd"

export var position_name = ""
signal clicked(position_name)

func _on_click():
	emit_signal("clicked", position_name)
