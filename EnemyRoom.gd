extends "Room.gd"

onready var key_card_scene = load("KeyCard.tscn")

func on_enemies_dead():
	var instance = key_card_scene.instance()
	instance.set_pos(Vector2(320, 240))
	add_child(instance)
