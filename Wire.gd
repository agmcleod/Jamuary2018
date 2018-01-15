extends "Hover.gd"

signal clicked(color)

export var color = ""

func _on_click():
	emit_signal("clicked", color)
	hide()

func _ready():
	._ready()
	add_to_group("wires")