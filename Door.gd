extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export var locked = false
export var exit_pos = Vector2(0, 0)
export var required_key_card = ""
export (NodePath) var exit_room

func can_open(player):
	if is_locked() && player.has_keycard(required_key_card):
		set_locked(false)
		player.use_keycard(required_key_card)
		return true

	return false

func is_locked():
	return locked

func set_locked(lock):
	locked = lock

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
