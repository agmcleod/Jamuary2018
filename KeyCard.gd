extends "Pickup.gd"

func on_pickup():
	var player = get_node("/root/Container/PlayerBody")
	player.call("give_keycard")
	queue_free()