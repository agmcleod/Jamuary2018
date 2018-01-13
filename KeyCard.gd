extends "Pickup.gd"

export var key_card_name = ""

func on_pickup():
	var player = get_node("/root/Container/PlayerBody")
	player.call("give_keycard", key_card_name)
	queue_free()