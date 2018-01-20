extends StaticBody2D

var locked = true

func is_locked():
	return locked

func unlock():
	locked = false

func _ready():
	pass
