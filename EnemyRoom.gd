extends "Room.gd"

onready var key_card_scene = load("KeyCard.tscn")

func on_goal_completed():
	var instance = key_card_scene.instance()
	instance.position = Vector2(320, 240)
	instance.key_card_name = "blue"
	add_child(instance)
