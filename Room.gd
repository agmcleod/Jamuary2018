extends Container

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var room_id = 0

func on_enemy_removed():
	var enemy_count = 0
	var door = null
	for child in get_children():
		if child.get_name().find("EnemyBody") != -1:
			enemy_count += 1
		elif child.get_name().find("Door") != -1:
			door = child

	if enemy_count <= 1 && door:
		door.call("set_locked", false)
		on_goal_completed()

func on_player_enter():
	var has_enemies = false
	for child in get_children():
		if child.get_name().find("EnemyBody") != -1:
			has_enemies = true
			child.call("start_attacking")

	if has_enemies:
		for child in get_children():
			if child.get_name().find("Door") != -1:
				child.call("set_locked", true)

func _ready():
	add_to_group("rooms")
	pass
