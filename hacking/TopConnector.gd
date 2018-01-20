extends "../Hover.gd"

export var cable_color = ""
signal clicked(color)

func _on_click():
	emit_signal("clicked", cable_color)
