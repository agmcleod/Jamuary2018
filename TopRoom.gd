extends "Room.gd"

onready var hack_tool_scene = load("HackTool.tscn")

func on_goal_completed():
	var instance = hack_tool_scene.instance()
	instance.set_pos(Vector2(320, 240))
	add_child(instance)
