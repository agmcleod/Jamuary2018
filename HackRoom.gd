extends "Room.gd"

onready var document_scene = load("Document.tscn")

func on_goal_completed():
	var instance = document_scene.instance()
	instance.position = Vector2(320, 240)
	add_child(instance)
